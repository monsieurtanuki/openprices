# openprices

A new Flutter project.

## How to get the shop OSM location id?

Find inspiration in https://overpass-turbo.eu/?Q=%2F*%0AThis%20is%20an%20example%20Overpass%20query.%0ATry%20it%20out%20by%20pressing%20the%20Run%20button%20above!%0AYou%20can%20find%20more%20examples%20with%20the%20Load%20tool.%0A*%2F%0Anode%0A%20%20%5Bamenity%3Ddrinking_water%5D%0A%20%20(%7B%7Bbbox%7D%7D)%3B%0Aout%3B&C=40.84618;14.25562;14&R
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

