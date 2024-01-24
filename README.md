# tswift-snow-on-the-beach

> Like snow on the beach, weird but fuckin' beautiful

Code to analyze anomalies in Taylor Swift albums.

**[Read the write up.](https://scarlettswerdlow.github.io/tswift-snow-on-the-beach/)**

## Usage

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
python3 src/find-outliers.py --tracks_raw <filepath to read raw tracks data> --tracks_processed <filepath to write processed tracks data> --verbose True
```

4. Make plots. For example:

```
Rscript src/make-track-length-plot.R <filepath to read processed tracks data> <filepath to read raw albums data> <filepath to write plot>
```
