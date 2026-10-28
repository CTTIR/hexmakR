# Browse the CTTIR v5 identities

The registry includes 37 R packages, five companion apps, two suites and
the CTTIR organisation identity. Exact spelling and case are preserved.

## Usage

``` r
hex_catalog(family = NULL)
```

## Arguments

- family:

  Optional family key used to filter the registry.

## Value

A data frame with identity, repository, family, symbol, kind and source.

## Examples

``` r
hex_catalog()
#>               name            repo     family          symbol          kind
#> 1         molpathR        molpathR   clinical        molpathR     R package
#> 2           pressR          pressR   clinical          pressR     R package
#> 3          scimagR         scimagR   clinical         scimagR     R package
#> 4      zhncommandR     zhncommandR   clinical     zhncommandR     R package
#> 5       brainwritR      brainwritR   evidence      brainwritR     R package
#> 6          delphyr         delphyR   evidence         delphyr     R package
#> 7       delphyrApp         delphyR   evidence      delphyrApp     R package
#> 8        researchR       researchR   evidence       researchR     R package
#> 9          scimapR         scimapR   evidence         scimapR     R package
#> 10      inferguidR      inferguidR    methods      inferguidR     R package
#> 11           songR           songR    methods           songR     R package
#> 12          sorenR          sorenR    methods          sorenR     R package
#> 13         bambamR         bambamR      omics         bambamR     R package
#> 14      qviewparsR      qviewparsR      omics      qviewparsR     R package
#> 15           cttiR           cttiR   platform           cttiR     R package
#> 16         harbouR         harbouR   platform         harbouR     R package
#> 17         hexmakR         hexmakR   platform         hexmakR     R package
#> 18         reflowR         reflowR   platform         reflowR     R package
#> 19         themakR         themakR   platform         themakR     R package
#> 20        dynasimR        dynasimR simulation        dynasimR     R package
#> 21       sandtablR       sandtablR simulation       sandtablR     R package
#> 22         shieldR         shieldR simulation         shieldR     R package
#> 23     bloodspottR     bloodspottR    spatial     bloodspottR     R package
#> 24     cellreportR     cellreportR    spatial     cellreportR     R package
#> 25       cellspecR       cellspecR    spatial       cellspecR     R package
#> 26       gatekeepR       gatekeepR    spatial       gatekeepR     R package
#> 27       mssrscopR       mssrscopR    spatial       mssrscopR     R package
#> 28      phenoscapR      phenoscapR    spatial      phenoscapR     R package
#> 29        qupflowR        qupflowR    spatial        qupflowR     R package
#> 30        segmantR        segmantR    spatial        segmantR     R package
#> 31         cuvis.r         cuvis.r   spectral         cuvis.r     R package
#> 32   hyperannotatR   hyperannotatR   spectral   hyperannotatR     R package
#> 33       hypermodR       hypermodR   spectral       hypermodR     R package
#> 34 hyperspectaculR hyperspectaculR   spectral hyperspectaculR     R package
#> 35     hyperspectR     hyperspectR   spectral     hyperspectR     R package
#> 36        libscanR        libscanR   spectral        libscanR     R package
#> 37         tivis.r         tivis.r   spectral         tivis.r     R package
#> 38           CTTIR         .github      brand           CTTIR  Organisation
#> 39       argus-one       argus-one   evidence       argus-one Companion app
#> 40 attaclone-dedup attaclone-dedup   evidence attaclone-dedup Companion app
#> 41 metadata-mender metadata-mender   evidence metadata-mender Companion app
#> 42       pwa-quest       pwa-quest   evidence       pwa-quest Companion app
#> 43    shinylaunchR    shinylaunchR   platform    shinylaunchR Companion app
#> 44       hyperloom                   spectral       hyperloom         Suite
#> 45       phenoloom                    spatial       phenoloom         Suite
#>                                                                        source
#> 1                     https://github.com/CTTIR/molpathR/blob/main/DESCRIPTION
#> 2                       https://github.com/CTTIR/pressR/blob/main/DESCRIPTION
#> 3                      https://github.com/CTTIR/scimagR/blob/main/DESCRIPTION
#> 4                  https://github.com/CTTIR/zhncommandR/blob/main/DESCRIPTION
#> 5                   https://github.com/CTTIR/brainwritR/blob/main/DESCRIPTION
#> 6     https://github.com/CTTIR/delphyR/blob/main/packages/delphyr/DESCRIPTION
#> 7  https://github.com/CTTIR/delphyR/blob/main/packages/delphyrApp/DESCRIPTION
#> 8                    https://github.com/CTTIR/researchR/blob/main/DESCRIPTION
#> 9                      https://github.com/CTTIR/scimapR/blob/main/DESCRIPTION
#> 10                  https://github.com/CTTIR/inferguidR/blob/main/DESCRIPTION
#> 11                       https://github.com/CTTIR/songR/blob/main/DESCRIPTION
#> 12                      https://github.com/CTTIR/sorenR/blob/main/DESCRIPTION
#> 13                     https://github.com/CTTIR/bambamR/blob/main/DESCRIPTION
#> 14                  https://github.com/CTTIR/qviewparsR/blob/main/DESCRIPTION
#> 15                       https://github.com/CTTIR/cttiR/blob/main/DESCRIPTION
#> 16                     https://github.com/CTTIR/harbouR/blob/main/DESCRIPTION
#> 17                     https://github.com/CTTIR/hexmakR/blob/main/DESCRIPTION
#> 18                     https://github.com/CTTIR/reflowR/blob/main/DESCRIPTION
#> 19                     https://github.com/CTTIR/themakR/blob/main/DESCRIPTION
#> 20                    https://github.com/CTTIR/dynasimR/blob/main/DESCRIPTION
#> 21                   https://github.com/CTTIR/sandtablR/blob/main/DESCRIPTION
#> 22                     https://github.com/CTTIR/shieldR/blob/main/DESCRIPTION
#> 23                 https://github.com/CTTIR/bloodspottR/blob/main/DESCRIPTION
#> 24                 https://github.com/CTTIR/cellreportR/blob/main/DESCRIPTION
#> 25                   https://github.com/CTTIR/cellspecR/blob/main/DESCRIPTION
#> 26                   https://github.com/CTTIR/gatekeepR/blob/main/DESCRIPTION
#> 27                   https://github.com/CTTIR/mssrscopR/blob/main/DESCRIPTION
#> 28                  https://github.com/CTTIR/phenoscapR/blob/main/DESCRIPTION
#> 29                    https://github.com/CTTIR/qupflowR/blob/main/DESCRIPTION
#> 30                    https://github.com/CTTIR/segmantR/blob/main/DESCRIPTION
#> 31                     https://github.com/CTTIR/cuvis.r/blob/main/DESCRIPTION
#> 32               https://github.com/CTTIR/hyperannotatR/blob/main/DESCRIPTION
#> 33                   https://github.com/CTTIR/hypermodR/blob/main/DESCRIPTION
#> 34             https://github.com/CTTIR/hyperspectaculR/blob/main/DESCRIPTION
#> 35                 https://github.com/CTTIR/hyperspectR/blob/main/DESCRIPTION
#> 36                    https://github.com/CTTIR/libscanR/blob/main/DESCRIPTION
#> 37                     https://github.com/CTTIR/tivis.r/blob/main/DESCRIPTION
#> 38                                                   https://github.com/CTTIR
#> 39                                         https://github.com/CTTIR/argus-one
#> 40                                   https://github.com/CTTIR/attaclone-dedup
#> 41                                   https://github.com/CTTIR/metadata-mender
#> 42                                         https://github.com/CTTIR/pwa-quest
#> 43                                      https://github.com/CTTIR/shinylaunchR
#> 44                                              User-specified suite identity
#> 45                                              User-specified suite identity
#>          asset_dir
#> 1         molpathR
#> 2           pressR
#> 3          scimagR
#> 4      zhncommandR
#> 5       brainwritR
#> 6          delphyr
#> 7       delphyrApp
#> 8        researchR
#> 9          scimapR
#> 10      inferguidR
#> 11           songR
#> 12          sorenR
#> 13         bambamR
#> 14      qviewparsR
#> 15           cttiR
#> 16         harbouR
#> 17         hexmakR
#> 18         reflowR
#> 19         themakR
#> 20        dynasimR
#> 21       sandtablR
#> 22         shieldR
#> 23     bloodspottR
#> 24     cellreportR
#> 25       cellspecR
#> 26       gatekeepR
#> 27       mssrscopR
#> 28      phenoscapR
#> 29        qupflowR
#> 30        segmantR
#> 31         cuvis.r
#> 32   hyperannotatR
#> 33       hypermodR
#> 34 hyperspectaculR
#> 35     hyperspectR
#> 36        libscanR
#> 37         tivis.r
#> 38     CTTIR-brand
#> 39       argus-one
#> 40 attaclone-dedup
#> 41 metadata-mender
#> 42       pwa-quest
#> 43    shinylaunchR
#> 44       hyperloom
#> 45       phenoloom
hex_catalog("spectral")
#>              name            repo   family          symbol      kind
#> 1         cuvis.r         cuvis.r spectral         cuvis.r R package
#> 2   hyperannotatR   hyperannotatR spectral   hyperannotatR R package
#> 3       hypermodR       hypermodR spectral       hypermodR R package
#> 4 hyperspectaculR hyperspectaculR spectral hyperspectaculR R package
#> 5     hyperspectR     hyperspectR spectral     hyperspectR R package
#> 6        libscanR        libscanR spectral        libscanR R package
#> 7         tivis.r         tivis.r spectral         tivis.r R package
#> 8       hyperloom                 spectral       hyperloom     Suite
#>                                                           source
#> 1         https://github.com/CTTIR/cuvis.r/blob/main/DESCRIPTION
#> 2   https://github.com/CTTIR/hyperannotatR/blob/main/DESCRIPTION
#> 3       https://github.com/CTTIR/hypermodR/blob/main/DESCRIPTION
#> 4 https://github.com/CTTIR/hyperspectaculR/blob/main/DESCRIPTION
#> 5     https://github.com/CTTIR/hyperspectR/blob/main/DESCRIPTION
#> 6        https://github.com/CTTIR/libscanR/blob/main/DESCRIPTION
#> 7         https://github.com/CTTIR/tivis.r/blob/main/DESCRIPTION
#> 8                                  User-specified suite identity
#>         asset_dir
#> 1         cuvis.r
#> 2   hyperannotatR
#> 3       hypermodR
#> 4 hyperspectaculR
#> 5     hyperspectR
#> 6        libscanR
#> 7         tivis.r
#> 8       hyperloom
```
