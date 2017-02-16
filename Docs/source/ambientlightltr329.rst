.. highlight:: Objective-C

AmbientLightLTR329
==================

This specific ambient light sensor is configured via properties on the `MBLAmbientLightLTR329 <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLAmbientLightLTR329.html>`_ class.  This section shows how to use its advanced features.

Periodic Readings
-----------------

This ambient light sensor has a built in timer, so you can program it directly to return periodic data.

::

    ambientLightLTR329.gain = MBLAmbientLightLTR329Gain1X;
    // Have the sensor measure over 100ms
    ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration100ms;
    // Perform a new measurement each second
    ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate1000ms;
    [ambientLightLTR329.periodicIlluminance startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"ambient light: %f lux", obj.value.floatValue);
    }];

