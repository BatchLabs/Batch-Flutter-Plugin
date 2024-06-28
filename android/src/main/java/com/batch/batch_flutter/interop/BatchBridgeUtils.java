package com.batch.batch_flutter.interop;

import com.batch.android.BatchEventAttributes;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

public class BatchBridgeUtils {

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

    @SuppressWarnings("unchecked")
    static BatchEventAttributes convertSerializedEventDataToEventAttributes(Map<String, Object> eventData) throws BatchBridgeException {
        BatchEventAttributes batchEventAttributes = null;
        if (eventData != null) {
            batchEventAttributes = new BatchEventAttributes();

            for (Map.Entry<String, Object> attributeEntry : eventData.entrySet()) {
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
                    batchEventAttributes.put(entryStringKey, getTypedParameter(entryMapValue, "value", String.class));
                } else if ("b".equals(type)) {
                    batchEventAttributes.put(entryStringKey, getTypedParameter(entryMapValue, "value", Boolean.class));
                } else if ("i".equals(type)) {
                    batchEventAttributes.put(entryStringKey, getTypedParameter(entryMapValue, "value", Number.class).longValue());
                } else if ("f".equals(type)) {
                    batchEventAttributes.put(entryStringKey, getTypedParameter(entryMapValue, "value", Number.class).doubleValue());
                } else if ("d".equals(type)) {
                    long timestamp = getTypedParameter(entryMapValue, "value", Number.class).longValue();
                    batchEventAttributes.put(entryStringKey, new Date(timestamp));
                } else if ("u".equals(type)) {
                    String rawURI = getTypedParameter(entryMapValue, "value", String.class);
                    try {
                        batchEventAttributes.put(entryStringKey, new URI(rawURI));
                    } catch (URISyntaxException e) {
                        throw new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_BRIDGE_ERROR, "Bad URL event data syntax", null, e);
                    }
                } else if ("o".equals(type)) {
                    batchEventAttributes.put(entryStringKey, convertSerializedEventDataToEventAttributes(getTypedParameter(entryMapValue, "value", Map.class)));
                } else if ("sa".equals(type)) {
                    batchEventAttributes.putStringList(entryStringKey,getTypedParameter(entryMapValue, "value", List.class));
                } else if ("oa".equals(type)) {
                    List<BatchEventAttributes> eventAttributesList = new ArrayList<>();
                    List<Map<String, Object>> list = getTypedParameter(entryMapValue, "value", List.class);
                    for (int i = 0; i < list.size(); i++) {
                        BatchEventAttributes object = convertSerializedEventDataToEventAttributes(list.get(i));
                        if (object != null) {
                            eventAttributesList.add(object);
                        }
                    }
                    batchEventAttributes.putObjectList(entryStringKey, eventAttributesList);
                } else {
                    throw new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_BRIDGE_ERROR, "Unknown event_data.attributes type");
                }
            }
        }
        return batchEventAttributes;
    }

}
