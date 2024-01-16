# openprices

A new Flutter project.

## How to get the shop OSM location id?

Find inspiration in
* https://overpass-turbo.eu/?Q=%2F*%0AThis%20is%20an%20example%20Overpass%20query.%0ATry%20it%20out%20by%20pressing%20the%20Run%20button%20above!%0AYou%20can%20find%20more%20examples%20with%20the%20Load%20tool.%0A*%2F%0Anode%0A%20%20%5Bamenity%3Ddrinking_water%5D%0A%20%20(%7B%7Bbbox%7D%7D)%3B%0Aout%3B&C=40.84618;14.25562;14&R
* https://dev.overpass-api.de/overpass-doc/en/criteria/per_tag.html
* https://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_QL
* https://overpass-api.de/api/interpreter?data=[out:json];nwr[shop](48.83563112422124,2.3995312901587167,48.838927808437255,2.402655965326046);out body;
* https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=48.8377287&lon=2.4014374
```
/*
This is an example Overpass query.
Try it out by pressing the Run button above!
You can find more examples with the Load tool.
*/
node
  [shop]
  ({{bbox}});
out;
```

