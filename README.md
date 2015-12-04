# pigeonhole

```
c = Pigeonhole::Collection.new([
  ['HERE', '#123', 2],
  ['THERE', '#123', 5],
  ['HERE', '#456', 1]
])

# Keyword arguments are cool
c.quantity(unit: '#123')                    => 7
c.quantity(location: 'HERE')                => 3
c.quantity(unit: '#123', location: 'HERE')  => 2
c.quantity(unit: '#456', location: 'THERE') => 0

c.include?(unit: '#456')                    => true
c.include?(unit: '#456', location: 'THERE') => false
c.include?(unit: '#123', quantity: 6)       => true

# Sometimes you need a big fat Array.
c.locations               => ["HERE", "HERE", "HERE", "THERE", "THERE", "THERE", "THERE", "THERE"] 
c.locations(unit: '#123') => ["HERE", "HERE", "THERE", "THERE", "THERE", "THERE", "THERE"] 

c.units                   => ["#123", "#123", "#456", "#123", "#123", "#123", "#123", "#123"] 
c.units(location: 'HERE') => ["#123", "#123", "#456"] 

# You can export your stuff
c.to_a => [["HERE", "#123", 2], ["HERE", "#456", 1], ["THERE", "#123", 5]] 

# You can compare Collections
c2 = Pigeonhole::Collection.new(['THERE', '#123', 5])
c.include?(c2) => true

# Or Arrays
c.include?(['THERE', '#123', 5]) => true
```
