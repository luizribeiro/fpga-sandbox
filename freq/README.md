# freq

In order to create a 150MHz clock from the 48MHz clock on the upduino,
create a `pll.v` module:

```
icepll -i 48 -o 150 -m -f pll.v
```
