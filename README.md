# tswift-snow-on-the-beach
*Like snow on the beach, weird but fuckin' beautiful*

Code to analyze anomalies in Taylor Swift albums.

**Usage**

1. Create raw datasets from [tswift-golden repo](https://github.com/scarlettswerdlow/tswift-golden/tree/main)

2. Install dependencies for Python and R

```
pip install -r reqs/python-requirements.txt
```

```
while IFS=" " read -r package version; 
do
    Rscript -e "devtools::install_version('"$package"', version='"$version"', repos='https://cloud.r-project.org')"; 
done < "reqs/r-requirements.txt"
```

3. Run `find-outliers.py`:

```
python3 src/find-outliers.py --tracks_raw <filepath to raw tracks data> --tracks_processed data/tracks_analytics.csv --verbose True
```

4. Make plots. For example:

```
Rscript src/make-track-length-plot.R data/tracks_analytics.csv <filepath to raw album data> viz/track-length-outliers.jpeg
```
