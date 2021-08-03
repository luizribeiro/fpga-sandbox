# orangecrab-blink

```
$ apio build
$ apio upload
```

For some reason, `apio upload` doesn't work but this does:

```
$ dfu-util -d 1209:5af0 -D hardware.bit
```
