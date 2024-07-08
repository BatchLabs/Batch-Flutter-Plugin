package com.batch.batch_flutter;

import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Simple manifest reader
 */
@RunWith(AndroidJUnit4.class)
public class ManifestReaderTest {
    private static final String EXPECTED_BOOL_KEY = "tests_bool";
    private static final String EXPECTED_STRING_KEY = "tests_string";

    @Test
    public void testBool() {
        ManifestReader manifestReader = new ManifestReader(ApplicationProvider.getApplicationContext());
        Assert.assertTrue(manifestReader.readBoolean(EXPECTED_BOOL_KEY, false));
        Assert.assertFalse(manifestReader.readBoolean("missing", false));
        Assert.assertTrue(manifestReader.readBoolean("missing", true));
    }

    @Test
    public void testString() {
        ManifestReader manifestReader = new ManifestReader(ApplicationProvider.getApplicationContext());
        Assert.assertEquals("stringvalue", manifestReader.readString(EXPECTED_STRING_KEY, null));
        Assert.assertNull(manifestReader.readString(EXPECTED_BOOL_KEY, null));
        Assert.assertNull(manifestReader.readString("missing", null));
        Assert.assertEquals("fallback", manifestReader.readString("missing", "fallback"));
    }
}
