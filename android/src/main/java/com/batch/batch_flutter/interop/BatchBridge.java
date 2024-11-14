package com.batch.batch_flutter.interop;

import static com.batch.batch_flutter.interop.BatchBridgeUtils.convertSerializedEventDataToEventAttributes;
import static com.batch.batch_flutter.interop.BatchBridgeUtils.getOptionalTypedParameter;
import static com.batch.batch_flutter.interop.BatchBridgeUtils.getTypedParameter;

import android.app.Activity;
import android.location.Location;
import android.util.Log;

import androidx.annotation.NonNull;

import com.batch.android.Batch;
import com.batch.android.BatchAttributesFetchListener;
import com.batch.android.BatchDataCollectionConfig;
import com.batch.android.BatchEmailSubscriptionState;
import com.batch.android.BatchEventAttributes;
import com.batch.android.BatchMessage;
import com.batch.android.BatchOptOutResultListener;
import com.batch.android.BatchProfileAttributeEditor;
import com.batch.android.BatchPushRegistration;
import com.batch.android.BatchSMSSubscriptionState;
import com.batch.android.BatchTagCollectionsFetchListener;
import com.batch.android.BatchUserAttribute;
import com.batch.batch_flutter.BatchFlutterLogger;
import com.batch.batch_flutter.Promise;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Bridge that allows code to use Batch's APIs via an action+parameters request, to easily bridge it to some kind of JSON RPC
 * <p>
 * For internal plugin use only
 */

public class BatchBridge {
    private static final String BRIDGE_VERSION_ENVIRONEMENT_VAR = "batch.bridge.version";

    private static final String BRIDGE_VERSION = "Bridge/1.0";

    private static final InboxBridge inboxBridge = new InboxBridge();

    static {
        System.setProperty(BRIDGE_VERSION_ENVIRONEMENT_VAR, BRIDGE_VERSION);
    }

    @SuppressWarnings("unused")
    public static Promise<Object> call(String action, Map<String, Object> parameters, Activity activity) {
        Promise<Object> result;

        try {
            result = doAction(action, parameters, activity);
        } catch (Exception e) {
            result = Promise.rejected(e);
        }

        return result;
    }

    @NonNull
    private static Promise<Object> doAction(String actionName, Map<String, Object> parameters, Activity activity) throws BatchBridgeException, BatchBridgeNotImplementedException {
        if (actionName == null || actionName.isEmpty()) {
            throw new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_BRIDGE_ERROR, "Invalid parameter : Empty or null action");
        }

        Action action;
        try {
            action = Action.fromName(actionName);
        } catch (IllegalArgumentException actionParsingException) {
            BatchFlutterLogger.e("Bridge action '" + actionName + "' is not implemented.");
            throw new BatchBridgeNotImplementedException(actionName);
        }

        switch (action) {
            case OPT_IN:
                optIn(activity);
                return Promise.resolved(null);
            case OPT_OUT:
                return optOut(activity, false);
            case OPT_OUT_AND_WIPE_DATA:
                return optOut(activity, true);
            case IS_OPTED_OUT:
                return Promise.resolved(Batch.isOptedOut(activity));
            case SET_AUTOMATIC_DATA_COLLECTION:
                setAutomaticDataCollection(parameters);
                return Promise.resolved(null);
            case MESSAGING_SET_DO_NOT_DISTURB_ENABLED:
                Batch.Messaging.setDoNotDisturbEnabled(getTypedParameter(parameters, "enabled", Boolean.class));
                return Promise.resolved(null);
            case MESSAGING_SHOW_PENDING_MESSAGE:
                showPendingMessage(activity);
                return Promise.resolved(null);
            case PUSH_GET_LAST_KNOWN_TOKEN:
                return Promise.resolved(getLastKnownPushToken());
            case PUSH_DISMISS_NOTIFICATIONS:
                dismissNotifications();
                return Promise.resolved(null);
            case PUSH_REQUEST_PERMISSION:
                Batch.Push.requestNotificationPermission(activity);
                return Promise.resolved(null);
            case PUSH_IOS_REFRESH_TOKEN:
            case PUSH_IOS_REQUEST_PROVISIONAL_PERMISSION:
            case PUSH_CLEAR_BADGE:
            case PUSH_IOS_SET_SHOW_FOREGROUND:
                // iOS only, do nothing
                return Promise.resolved(null);
            case USER_GET_INSTALLATION_ID:
                return Promise.resolved(Batch.User.getInstallationID());
            case USER_GET_IDENTIFIER:
                return Promise.resolved(Batch.User.getIdentifier(activity));
            case USER_GET_LANGUAGE:
                return Promise.resolved(Batch.User.getLanguage(activity));
            case USER_GET_REGION:
                return Promise.resolved(Batch.User.getRegion(activity));
            case USER_CLEAR_INSTALLATION_DATA:
                Batch.User.clearInstallationData();
                return Promise.resolved(null);
            case PROFILE_IDENTIFY:
                identify(parameters);
                return Promise.resolved(null);
            case PROFILE_EDIT:
                editProfileAttributes(parameters);
                return Promise.resolved(null);
            case PROFILE_TRACK_EVENT:
                return trackEvent(parameters);
            case PROFILE_TRACK_LOCATION:
                trackLocation(parameters);
                return Promise.resolved(null);
            case USER_FETCH_ATTRIBUTES:
                return userFetchAttributes(activity);
            case USER_FETCH_TAGS:
                return userFetchTags(activity);
            case DEBUG_SHOW_DEBUG_VIEW:
                showDebugView(activity);
                return Promise.resolved(null);

            case INBOX_CREATE_INSTALLATION_FETCHER:
            case INBOX_CREATE_USER_FETCHER:
            case INBOX_RELEASE_FETCHER:
            case INBOX_FETCH_NEW_NOTIFICATIONS:
            case INBOX_FETCH_NEXT_PAGE:
            case INBOX_GET_FETCHED_NOTIFICATIONS:
            case INBOX_MARK_AS_READ:
            case INBOX_MARK_ALL_AS_READ:
            case INBOX_MARK_AS_DELETED:
            case INBOX_DISPLAY_LANDING:
                return inboxBridge.doAction(action, parameters, activity);

            case ECHO:
                return Promise.resolved(parameters.get("value"));
            default:
                throw new BatchBridgeNotImplementedException(actionName);
        }
    }



    private static void optIn(Activity activity) {
        Batch.optIn(activity);
        Batch.onStart(activity);
    }

    private static Promise<Object> optOut(Activity activity, boolean wipeData) {
        return new Promise<>(promise -> {

            BatchOptOutResultListener resultListener = new BatchOptOutResultListener() {
                @Override
                public void onSuccess() {
                    promise.resolve(null);
                }

                @Override
                public ErrorPolicy onError() {
                    promise.resolve(null);
                    return ErrorPolicy.IGNORE;
                }
            };

            if (wipeData) {
                Batch.optOutAndWipeData(activity, resultListener);
            } else {
                Batch.optOut(activity, resultListener);
            }
        });
    }

    @SuppressWarnings({"unchecked"})
    private static void setAutomaticDataCollection(Map<String, Object> parameters) throws BatchBridgeException {
        Map<String, Object> serializedConfig = getTypedParameter(parameters, "dataCollectionConfig", Map.class);
        Batch.updateAutomaticDataCollection(config -> {
            config.setDeviceBrandEnabled(getOptionalTypedParameter(serializedConfig, "deviceBrand", Boolean.class, null));
            config.setDeviceModelEnabled(getOptionalTypedParameter(serializedConfig, "deviceModel", Boolean.class, null));
            config.setGeoIPEnabled(getOptionalTypedParameter(serializedConfig, "geoIP", Boolean.class, null));
        });
    }

    private static String getLastKnownPushToken() {
        BatchPushRegistration registration = Batch.Push.getRegistration();
        return registration != null ? registration.getToken() : null;
    }

    private static void dismissNotifications() {
        Batch.Push.dismissNotifications();
    }

//region Profile

    private static void identify(Map<String, Object> parameters) throws BatchBridgeException {
        Object identifier = parameters.get("identifier");
        if (identifier != null && !(identifier instanceof String)) {
            throw new BatchBridgeException(BatchBridgePublicErrorCode.BAD_BRIDGE_ARGUMENT_TYPE, "Identifier can only be a string or null");
        }
        Batch.Profile.identify((String) identifier);
    }

    @SuppressWarnings({"unchecked", "ConstantConditions"})
    private static void editProfileAttributes(Map<String, Object> parameters) throws BatchBridgeException {
        try {
            List<Map<String, Object>> operations = getTypedParameter(parameters, "operations", List.class);
            if (operations == null) {
                return;
            }

            BatchProfileAttributeEditor editor = Batch.Profile.editor();

            for (Map<String, Object> operationDescription : operations) {
                String operationName = getTypedParameter(operationDescription, "operation", String.class);

                switch (operationName) {
                    case "SET_LANGUAGE": {
                        Object value = operationDescription.get("value");

                        if (value != null && !(value instanceof String)) {
                            Log.e("Batch Bridge", "Invalid SET_LANGUAGE value: it can only be a string or null");
                            // Invalid value, continue. NULL is allowed though
                            continue;
                        }

                        editor.setLanguage((String) value);
                        break;
                    }
                    case "SET_REGION": {
                        Object value = operationDescription.get("value");

                        if (value != null && !(value instanceof String)) {
                            Log.e("Batch Bridge", "Invalid SET_REGION value: it can only be a string or null");
                            // Invalid value, continue. NULL is allowed though
                            continue;
                        }

                        editor.setRegion((String) value);
                        break;
                    }
                    case "SET_EMAIL_ADDRESS": {
                        Object value = operationDescription.get("value");

                        if (value != null && !(value instanceof String)) {
                            // Invalid value, continue. NULL is allowed though
                            continue;
                        }

                        editor.setEmailAddress((String) value);
                        break;
                    }
                    case "SET_EMAIL_MARKETING_SUBSCRIPTION": {
                        Object value = operationDescription.get("value");
                        if ("subscribed".equals(value)) {
                            editor.setEmailMarketingSubscription(BatchEmailSubscriptionState.SUBSCRIBED);
                        } else if ("unsubscribed".equals(value)) {
                            editor.setEmailMarketingSubscription(BatchEmailSubscriptionState.UNSUBSCRIBED);
                        } else {
                            Log.e("Batch Bridge", "Invalid SET_EMAIL_MARKETING_SUBSCRIPTION value: it can only be `subscribed` or `unsubscribed`.");
                        }
                        break;
                    }
                    case "SET_PHONE_NUMBER": {
                        Object value = operationDescription.get("value");

                        if (value != null && !(value instanceof String)) {
                            // Invalid value, continue. NULL is allowed though
                            continue;
                        }

                        editor.setPhoneNumber((String) value);
                        break;
                    }
                    case "SET_SMS_MARKETING_SUBSCRIPTION": {
                        Object value = operationDescription.get("value");
                        if ("subscribed".equals(value)) {
                            editor.setSMSMarketingSubscription(BatchSMSSubscriptionState.SUBSCRIBED);
                        } else if ("unsubscribed".equals(value)) {
                            editor.setSMSMarketingSubscription(BatchSMSSubscriptionState.UNSUBSCRIBED);
                        } else {
                            Log.e("Batch Bridge", "Invalid SET_SMS_MARKETING_SUBSCRIPTION value: it can only be `subscribed` or `unsubscribed`.");
                        }
                        break;
                    }
                    case "SET_ATTRIBUTE": {
                        String key = getTypedParameter(operationDescription, "key", String.class);
                        String type = getTypedParameter(operationDescription, "type", String.class);

                        switch (type) {
                            case "string":
                                editor.setAttribute(key, getTypedParameter(operationDescription, "value", String.class));
                                break;
                            case "url":
                                try {
                                    editor.setAttribute(key, new URI(getTypedParameter(operationDescription, "value", String.class)));
                                } catch (URISyntaxException e) {
                                    Log.e("Batch Bridge", "Invalid SET_ATTRIBUTE url value: couldn't parse value", e);
                                }
                                break;
                            case "date":
                                editor.setAttribute(key, new Date(getTypedParameter(operationDescription, "value", Number.class).longValue()));
                                break;
                            case "integer": {
                                Object rawValue = operationDescription.get("value");

                                if (rawValue instanceof Number) {
                                    editor.setAttribute(key, ((Number) rawValue).longValue());
                                } else if (rawValue instanceof String) {
                                    try {
                                        editor.setAttribute(key, Long.parseLong((String) rawValue));
                                    } catch (NumberFormatException e) {
                                        Log.e("Batch Bridge", "Invalid SET_ATTRIBUTE integer value: couldn't parse value", e);
                                    }
                                }
                                break;
                            }
                            case "float": {
                                Object rawValue = operationDescription.get("value");

                                if (rawValue instanceof Number) {
                                    editor.setAttribute(key, ((Number) rawValue).doubleValue());
                                } else if (rawValue instanceof String) {
                                    try {
                                        editor.setAttribute(key, Double.parseDouble((String) rawValue));
                                    } catch (NumberFormatException e) {
                                        Log.e("Batch Bridge", "Invalid SET_ATTRIBUTE float value: couldn't parse value", e);
                                    }
                                }
                                break;
                            }
                            case "boolean": {
                                Object rawValue = operationDescription.get("value");

                                if (rawValue instanceof Boolean) {
                                    editor.setAttribute(key, (Boolean) rawValue);
                                } else if (rawValue instanceof String) {
                                    try {
                                        editor.setAttribute(key, Boolean.parseBoolean((String) rawValue));
                                    } catch (NumberFormatException e) {
                                        Log.e("Batch Bridge", "Invalid SET_ATTRIBUTE boolean value: couldn't parse value", e);
                                    }
                                }
                                break;
                            }
                            case "array": {
                                List<String> value = new ArrayList<String>(getTypedParameter(operationDescription, "value", ArrayList.class));
                                if (value != null) {
                                    editor.setAttribute(key, value);
                                }
                                break;
                            }
                        }
                        break;
                    }
                    case "REMOVE_ATTRIBUTE": {
                        String key = getTypedParameter(operationDescription, "key", String.class);
                        editor.removeAttribute(key);
                        break;
                    }
                    case "ADD_TO_ARRAY": {
                        String key = getTypedParameter(operationDescription, "key", String.class);
                        String value = getTypedParameter(operationDescription, "value", String.class);
                        editor.addToArray(key, value);
                        break;
                    }
                    case "REMOVE_FROM_ARRAY": {
                        String key = getTypedParameter(operationDescription, "key", String.class);
                        String value = getTypedParameter(operationDescription, "value", String.class);
                        editor.removeFromArray(key, value);
                        break;
                    }
                }
            }
            editor.save();
        } catch (ClassCastException e) {
            throw new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_BRIDGE_ERROR, "Error while decoding user data operations ", null, e);
        }
    }

    private static Promise<Object> trackEvent(Map<String, Object> parameters) {
        return new Promise<>(promise -> {
            String name = null;
            try {
                name = getTypedParameter(parameters, "name", String.class);
            } catch (BatchBridgeException e) {
                promise.reject(new BatchBridgeException(BatchBridgePublicErrorCode.BAD_BRIDGE_ARGUMENT_TYPE, "Missing event name parameter."));
                return;
            }
            Map<String, Object>  data = null;
            try {
                data = getTypedParameter(parameters, "event_data", Map.class);
            } catch (BatchBridgeException e) {
                // Event data are optionals, disregard the exception
            }
            if (data != null) {
                try {
                    BatchEventAttributes batchEventAttributes = convertSerializedEventDataToEventAttributes(data);
                    List<String> errors = batchEventAttributes.validateEventAttributes();
                    if (errors.isEmpty()) {
                        Batch.Profile.trackEvent(name, batchEventAttributes);
                        promise.resolve(null);
                    } else {
                        promise.reject(new BatchBridgeException(BatchBridgePublicErrorCode.BAD_BRIDGE_ARGUMENT_TYPE, errors.toString()));
                    }
                } catch (BatchBridgeException e) {
                    promise.reject(e);
                }
            } else {
                Batch.Profile.trackEvent(name, null);
            }
        });
    }

    private static void trackLocation(Map<String, Object> parameters) throws BatchBridgeException {
        double latitude = getTypedParameter(parameters, "latitude", Number.class).doubleValue();
        double longitude = getTypedParameter(parameters, "longitude", Number.class).doubleValue();

        Integer precision = null;
        try {
            precision = getTypedParameter(parameters, "precision", Integer.class);
        } catch (BatchBridgeException e) {
            // The parameter is optional, disregard the exception
        }

        Number date = null;
        try {
            date = getTypedParameter(parameters, "date", Number.class);
        } catch (BatchBridgeException e) {
            // The parameter is optional, disregard the exception
        }

        Location location = new Location("com.batch.batch_flutter.interop");
        location.setLatitude(latitude);
        location.setLongitude(longitude);

        if (precision != null) {
            location.setAccuracy(precision.floatValue());
        }

        if (date != null) {
            location.setTime(date.longValue());
        }

        Batch.Profile.trackLocation(location);
    }
    // endregion

    //region User Data
    private static Promise<Object> userFetchAttributes(Activity activity) {
        return new Promise<>(promise -> {
            Batch.User.fetchAttributes(activity, new BatchAttributesFetchListener() {
                @Override
                public void onSuccess(@NonNull Map<String, BatchUserAttribute> map) {
                    Map<String, Map<String, Object>> bridgeAttributes = new HashMap<>();

                    for (Map.Entry<String, BatchUserAttribute> attributeEntry : map.entrySet()) {
                        Map<String, Object> typedBrdigeAttribute = new HashMap<>();
                        BatchUserAttribute attribute = attributeEntry.getValue();

                        String type;
                        Object value = attribute.value;
                        switch (attribute.type) {
                            case BOOL:
                                type = "b";
                                break;
                            case DATE: {
                                type = "d";
                                Date dateValue = attribute.getDateValue();
                                if (dateValue == null) {
                                    promise.reject(new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_BRIDGE_ERROR,
                                            "Fetch attribute: Could not parse date for key: " + attributeEntry.getKey()));
                                    return;
                                }
                                value = dateValue.getTime();
                                break;
                            }
                            case STRING:
                                type = "s";
                                break;
                            case URL:
                                type = "u";
                                URI uriValue = attribute.getUriValue();
                                if (uriValue == null) {
                                    promise.reject(new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_BRIDGE_ERROR,
                                            "Fetch attribute: Could not parse URI for key: " + attributeEntry.getKey()));
                                    return;
                                }
                                value = uriValue.toString();
                                break;
                            case LONGLONG:
                                type = "i";
                                break;
                            case DOUBLE:
                                type = "f";
                                break;
                            default:
                                promise.reject(new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_BRIDGE_ERROR,
                                        "Fetch attribute: Unknown attribute type " + attribute.type + " for key: " + attributeEntry.getKey()));
                                return;
                        }

                        typedBrdigeAttribute.put("type", type);
                        typedBrdigeAttribute.put("value", value);

                        bridgeAttributes.put(attributeEntry.getKey(), typedBrdigeAttribute);
                    }


                    promise.resolve(bridgeAttributes);
                }

                @Override
                public void onError() {
                    promise.reject(new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_SDK_ERROR, "Native fetchAttributes returned an error"));
                }
            });
        });
    }

    private static Promise<Object> userFetchTags(Activity activity) {
        return new Promise<>(promise -> {
            Batch.User.fetchTagCollections(activity, new BatchTagCollectionsFetchListener() {
                @Override
                public void onSuccess(@NonNull Map<String, Set<String>> map) {
                    Map<String, List<String>> bridgeTagCollections = new HashMap<>();

                    for (Map.Entry<String, Set<String>> tagCollection : map.entrySet()) {
                        bridgeTagCollections.put(tagCollection.getKey(), new ArrayList<>(tagCollection.getValue()));
                    }

                    promise.resolve(bridgeTagCollections);
                }

                @Override
                public void onError() {
                    promise.reject(new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_SDK_ERROR, "Native fetchTagCollections returned an error"));
                }
            });
        });
    }

    private static void showPendingMessage(Activity activity) {
        BatchMessage msg = Batch.Messaging.popPendingMessage();
        if (msg != null) {
            Batch.Messaging.show(activity, msg);
        }
    }

    private static void showDebugView(Activity activity) {
        Batch.Debug.startDebugActivity(activity);
    }

//endregion
}
