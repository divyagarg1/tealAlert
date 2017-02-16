.. highlight:: Objective-C

Data
====

Synchronous data from MetaWear modules are exposed as `MBLData <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLData.html>`_ objects.  You can think of these objects as a piece data sitting on the MetaWear that can be read whenever you want.  These objects have abstractions for performing one time or periodic reads.

In this section we will explain the generic features available to all data objects by going over a couple of useful examples. Note that detailed documentation for each module's events can be found in the individual module sections below.

Read
----

One of the most basic use cases is to simply receive the data on your Apple device.

::

    MBLGPIOPin *pin0 = self.device.gpio.pins[0];
    [[pin0.digitalValue readAsync] success:^(MBLNumericData * _Nonnull result) {
        NSLog(@"Pin Value: %@", result);
        result.value.boolValue ? NSLog(@"Pressed!") : NSLog(@"Released!");
    }];

Periodic Reads
--------------

By periodically reading data, you conceptually turn it into an asynchronous event.  The periodic read function allows you to create `MBLEvent <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLEvent.html>`_ from `MBLData <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLData.html>`_.  This helps to explain the fundamental difference between event and data objects: events tell you when they have data (asynchronous), whereas data objects wait to be read (synchronous).

::

    MBLGPIOPin *pin0 = device.gpio.pins[0];
    MBLEvent *periodicPinValue = [pin0.analogAbsolute periodicReadWithPeriod:100];
    [periodicPinValue startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"Analog Value: %@", obj);
    }];

Triggered Reads
---------------

Another interesting feature is the ability to have an ``MBLEvent`` trigger a read of data.  This allows you to do things like read data on button press.

::

    // NOTE: This i2c register is just an example, it might not return anything on your exact board
    MBLI2CData *whoami = [device.serial dataAtDeviceAddress:0x1C registerAddress:0x0D length:1];
    MBLEvent *event = [device.mechanicalSwitch.switchUpdateEvent readDataOnEvent:whoami];
    [event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"%@", obj);
    }];

