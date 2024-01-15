# tswift-snow-on-the-beach
Code to analyze anomalies in Taylor Swift albums.

*Like snow on the beach, weird but fuckin' beautiful*

**Usage**

1. Create raw datasets from [tswift-golden repo](https://github.com/scarlettswerdlow/tswift-golden/tree/main)

2. Install dependencies

```
pip install -r requirements.tx
```

2. Run `find-outliers.py`:

```
python3 src/find-outliers.py --tracks_raw <filepath to raw tracks data> --tracks_processed data/tracks_analytics.csv --verbose True
```
