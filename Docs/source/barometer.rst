.. highlight:: Objective-C

Barometer
=========

Some MetaWear boards comes with a builtin barometer.  It's configured via properties on the `MBLBarometer <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLBarometer.html>`_ class.

To meet specific needs, different MetaWear models have different barometers, so the ``MBLBarometer`` class is actually a generic abstraction of all barometers.  You can up-cast to one of our derived barometer objects in order to access advanced features.

Pressure Reading
----------------

One thing common to all ambient light sensors is the ability to measure the ambient air pressure.

::

    [[device.barometer.pressure readAsync] success:^(MBLNumericData * _Nonnull result) {
        NSLog(@"pressure: %f pascals", result.value.floatValue);
    }];

Altitude Reading
----------------

Often times what you really want is an estimation of current altitude above sea level.  Since it's a complex non-linear function to get altitude from pressure, we have it built right in.

::

    [[device.barometer.altitude readAsync] success:^(MBLNumericData * _Nonnull result) {
        NSLog(@"altitude: %f meters", result.value.floatValue);
    }];

Cast to Derived Class
---------------------

To use advanced barometer features it's necessary to figure out exactly what barometer your MetaWear has.

::

    if ([device.barometer isKindOfClass:[MBLBarometerBMP280 class]]) {
        MBLBarometerBMP280 *barometerBMP280 = (MBLBarometerBMP280 *)device.barometer;
    }

