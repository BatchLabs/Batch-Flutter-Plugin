package com.batch.batch_flutter.interop;

import android.app.Activity;
import android.location.Location;
import android.util.Log;

import androidx.annotation.NonNull;

import com.batch.android.Batch;
import com.batch.android.BatchAttributesFetchListener;
import com.batch.android.BatchEmailSubscriptionState;
import com.batch.android.BatchEventData;
import com.batch.android.BatchMessage;
import com.batch.android.BatchOptOutResultListener;
import com.batch.android.BatchTagCollectionsFetchListener;
import com.batch.android.BatchUserAttribute;
import com.batch.android.BatchUserDataEditor;
import com.batch.android.json.JSONObject;
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

    private static final String BRIDGE_VERSION = "Bridge/1.2";

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
        if (actionName == null || actionName.length() == 0) {
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
            case USER_EDIT:
                userDataEdit(parameters);
                return Promise.resolved(null);
            case USER_TRACK_EVENT:
                trackEvent(parameters);
                return Promise.resolved(null);
            case USER_TRACK_LOCATION:
                trackLocation(parameters);
                return Promise.resolved(null);
            case USER_TRACK_TRANSACTION:
                trackTransaction(parameters);
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

    @SuppressWarnings("unchecked")
    static <T> T getTypedParameter(Map<String, Object> parameters, String parameterName, Class<T> parameterClass) throws BatchBridgeException {
        Object result = null;

        if (parameters != null) {
            result = parameters.get(parameterName);
        }

        if (result == null) {
            throw new BatchBridgeException(BatchBridgePublicErrorCode.BAD_BRIDGE_ARGUMENT_TYPE, "Required parameter '" + parameterName + "' missing");
        }

        if (!parameterClass.isInstance(result)) {
            throw new BatchBridgeException(BatchBridgePublicErrorCode.BAD_BRIDGE_ARGUMENT_TYPE, "Required parameter '" + parameterName + "' of wrong type");
        }

        return (T) result;
    }

    @SuppressWarnings("unchecked")
    static <T> T getOptionalTypedParameter(Map<String, Object> parameters, String parameterName, Class<T> parameterClass, T fallback) {
        Object result = null;

        if (parameters != null) {
            result = parameters.get(parameterName);
        }

        if (result == null || !parameterClass.isInstance(result)) {
            return fallback;
        }

        return (T) result;
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

    private static String getLastKnownPushToken() {
        return Batch.Push.getLastKnownPushToken();
    }

    private static void dismissNotifications() {
        Batch.Push.dismissNotifications();
    }

//region User Data

    private static void userDataEdit(Map<String, Object> parameters) throws BatchBridgeException {
        try {
            //noinspection unchecked
            List<Map<String, Object>> operations = getTypedParameter(parameters, "operations", List.class);

            if (operations == null) {
                return;
            }

            BatchUserDataEditor editor = Batch.User.editor();

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
                    case "SET_IDENTIFIER": {
                        Object value = operationDescription.get("value");

                        if (value != null && !(value instanceof String)) {
                            Log.e("Batch Bridge", "Invalid SET_IDENTIFIER value: it can only be a string or null");
                            // Invalid value, continue. NULL is allowed though
                            continue;
                        }

                        editor.setIdentifier((String) value);
                        break;
                    }
                    case "SET_EMAIL": {
                        Object value = operationDescription.get("value");

                        if (value != null && !(value instanceof String)) {
                            // Invalid value, continue. NULL is allowed though
                            continue;
                        }

                        editor.setEmail((String) value);
                        break;
                    }
                    case "SET_EMAIL_MARKETING_SUBSCRIPTION": {
                        Object value = operationDescription.get("value");
                        if ("subscribed".equals(value)) {
                            editor.setEmailMarketingSubscriptionState(BatchEmailSubscriptionState.SUBSCRIBED);
                        } else if ("unsubscribed".equals(value)) {
                            editor.setEmailMarketingSubscriptionState(BatchEmailSubscriptionState.UNSUBSCRIBED);
                        } else {
                            Log.e("Batch Bridge", "Invalid SET_EMAIL_MARKETING_SUBSCRIPTION value: it can only be `subscribed` or `unsubscribed`.");
                        }
                        break;
                    }
                    case "SET_ATTRIBUTION_ID": {
                        Object value = operationDescription.get("value");

                        if (value != null && !(value instanceof String)) {
                            Log.e("Batch Bridge", "Invalid SET_ATTRIBUTION_ID value: it can only be a string or null");
                            // Invalid value, continue. NULL is allowed though
                            continue;
                        }

                        editor.setAttributionIdentifier((String) value);
                        break;
                    }
                    case "SET_ATTRIBUTE":
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
                        }
                        break;
                    case "REMOVE_ATTRIBUTE":
                        editor.removeAttribute(getTypedParameter(operationDescription, "key", String.class));
                        break;
                    case "CLEAR_ATTRIBUTES":
                        editor.clearAttributes();
                        break;
                    case "ADD_TAG": {
                        String tag = getTypedParameter(operationDescription, "tag", String.class);
                        String collection = getTypedParameter(operationDescription, "collection", String.class);

                        editor.addTag(collection, tag);
                        break;
                    }
                    case "REMOVE_TAG": {
                        String tag = getTypedParameter(operationDescription, "tag", String.class);
                        String collection = getTypedParameter(operationDescription, "collection", String.class);

                        editor.removeTag(collection, tag);
                        break;
                    }
                    case "CLEAR_TAGS":
                        editor.clearTags();
                        break;
                    case "CLEAR_TAG_COLLECTION":
                        editor.clearTagCollection(getTypedParameter(operationDescription, "collection", String.class));
                        break;
                }
            }

            editor.save();
        } catch (ClassCastException e) {
            throw new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_BRIDGE_ERROR, "Error while decoding user data operations ", null, e);
        }
    }

    private static void trackEvent(Map<String, Object> parameters) throws BatchBridgeException {
        String name = getTypedParameter(parameters, "name", String.class);

        String label = null;
        try {
            label = getTypedParameter(parameters, "label", String.class);
        } catch (BatchBridgeException e) {
            // The parameter is optional, disregard the exception
        }

        Map data = null;
        try {
            data = getTypedParameter(parameters, "event_data", Map.class);
        } catch (BatchBridgeException e) {
            // The parameter is optional, disregard the exception
        }

        BatchEventData batchEventData = null;

        if (data != null) {
            batchEventData = new BatchEventData();
            List tags = getTypedParameter(data, "tags", List.class);
            Map<String, Object> attributes = getTypedParameter(data, "attributes", Map.class);

            for (Object tag : tags) {
                if (tag instanceof String) {
                    batchEventData.addTag((String) tag);
                }
            }

            for (Map.Entry<String, Object> attributeEntry : attributes.entrySet()) {
                Object entryKey = attributeEntry.getKey();
                Object entryValue = attributeEntry.getValue();
                if (!(entryKey instanceof String)) {
                    continue;
                }
                if (!(entryValue instanceof Map)) {
                    continue;
                }
                String entryStringKey = (String) entryKey;
                Map<String, Object> entryMapValue = (Map<String, Object>) entryValue;
                String type = getTypedParameter(entryMapValue, "type", String.class);

                if ("s".equals(type)) {
                    batchEventData.put(entryStringKey, getTypedParameter(entryMapValue, "value", String.class));
                } else if ("b".equals(type)) {
                    batchEventData.put(entryStringKey, getTypedParameter(entryMapValue, "value", Boolean.class));
                } else if ("i".equals(type)) {
                    batchEventData.put(entryStringKey, getTypedParameter(entryMapValue, "value", Number.class).longValue());
                } else if ("f".equals(type)) {
                    batchEventData.put(entryStringKey, getTypedParameter(entryMapValue, "value", Number.class).doubleValue());
                } else if ("d".equals(type)) {
                    long timestamp = getTypedParameter(entryMapValue, "value", Number.class).longValue();
                    batchEventData.put(entryStringKey, new Date(timestamp));
                } else if ("u".equals(type)) {
                    String rawURI = getTypedParameter(entryMapValue, "value", String.class);
                    try {
                        batchEventData.put(entryStringKey, new URI(rawURI));
                    } catch (URISyntaxException e) {
                        throw new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_BRIDGE_ERROR, "Bad URL event data syntax", null, e);
                    }
                } else {
                    throw new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_BRIDGE_ERROR, "Unknown event_data.attributes type");
                }
            }
        }

        Batch.User.trackEvent(name, label, batchEventData);
    }

    private static void trackTransaction(Map<String, Object> parameters) throws BatchBridgeException {
        double amount = getTypedParameter(parameters, "amount", Number.class).doubleValue();

        Map data = null;
        try {
            data = getTypedParameter(parameters, "data", Map.class);
        } catch (BatchBridgeException e) {
            // The parameter is optional, disregard the exception
        }

        JSONObject jsonData = null;

        if (data != null) {
            jsonData = new JSONObject(data);
        }

        Batch.User.trackTransaction(amount, jsonData);
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
            Number rawDate = getTypedParameter(parameters, "date", Number.class);
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

        Batch.User.trackLocation(location);
    }

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
