# 0.1.0-rc1
* Initial proof of concept.
* Ecto usage is difficult as a library app.

# 0.1.0-rc2
* Add TCP transport.
* Remove JSON handler.
* Replace `Ecto` with `:mnesia` for ease of setup as library.
* Unseperate `Sensor` and `SensorValues` as their own resource.
  * This was to ease the transition to `:mnesia`
