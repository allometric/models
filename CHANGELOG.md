# allometric/models changelog

# [2.3.0](https://github.com/allometric/models/compare/v2.2.0...v2.3.0) (2024-04-13)


### Bug Fixes

* adjusting barnes_1962 prediction function ([437fed0](https://github.com/allometric/models/commit/437fed053a2405a94e0b8630f7576a4486fd9e8e))
* removing model install run on PR, closes [#55](https://github.com/allometric/models/issues/55) ([e251928](https://github.com/allometric/models/commit/e2519283b7d4c5fc69fc0a2e00913c9ad2822ce2))
* resolved issues in forrester_2017 variable names and taxa ([20989c0](https://github.com/allometric/models/commit/20989c0faa4e197907f1ff3e33905221651d3469))


### Features

* added cairns_2003, closes [#43](https://github.com/allometric/models/issues/43) ([dd4e412](https://github.com/allometric/models/commit/dd4e4128fc8fa6b9dfe2c8bcaa3e0eeb688b0a46))
* adding barnes_1962 ([abbbc1b](https://github.com/allometric/models/commit/abbbc1b7c3c062d13fd8ed673ad235d0d425313f))
* adding bricnkell_1966 ([d3aebd7](https://github.com/allometric/models/commit/d3aebd7e83b055ea7a951bf8e4dd1534c4cf9253))
* adding forrester_2017, closes [#38](https://github.com/allometric/models/issues/38) ([62e8c8f](https://github.com/allometric/models/commit/62e8c8f1d8240f6cb2653d3c5673c49c4923c522))

# [2.2.0](https://github.com/allometric/models/compare/v2.1.0...v2.2.0) (2023-12-28)


### Features

* implemented direct model.RDS downloading ([4994439](https://github.com/allometric/models/commit/49944390b3b58eba3312f74c32ba6dddd2c0f2d4))

# [2.1.0](https://github.com/allometric/models/compare/v2.0.0...v2.1.0) (2023-12-10)


### Features

* adding barrett_2006, closes [#39](https://github.com/allometric/models/issues/39) ([e41c224](https://github.com/allometric/models/commit/e41c224096f556185a4fb121f906eaf9dbd9600a))
* adding castaneda_2005, closes [#35](https://github.com/allometric/models/issues/35) ([56ac7b8](https://github.com/allometric/models/commit/56ac7b875a6a092bdaa12dac6d4c60f11399640f))
* adding hughes_1999, closes [#36](https://github.com/allometric/models/issues/36) ([1def94e](https://github.com/allometric/models/commit/1def94ec70f68b4f567352666d2771e27a18a51d))
* adding rolim_2019, updates [#37](https://github.com/allometric/models/issues/37) ([b53e024](https://github.com/allometric/models/commit/b53e024e75cd1d16fc3b28ad5e040b618b3d6ed3))
* adding rolim_2019b, closes [#37](https://github.com/allometric/models/issues/37) ([dac3c33](https://github.com/allometric/models/commit/dac3c33692607d71bd3d13ba7d07055f6ced2600))

# [2.0.0](https://github.com/allometric/models/compare/v1.1.2...v2.0.0) (2023-10-29)


### Bug Fixes

* correctly specifying feldpausch_2012 pantropical model country descriptor ([880303a](https://github.com/allometric/models/commit/880303a0c5ac27216b90874f824ae8ad7b19d252))
* defining site index base age for hahn_1984 models, closes [#19](https://github.com/allometric/models/issues/19) ([ddc9b81](https://github.com/allometric/models/commit/ddc9b81ccb39cd5c247fe7eb7866674e33de299e))
* defining site index base age for hahn_1991 models, closes [#20](https://github.com/allometric/models/issues/20) ([979df5c](https://github.com/allometric/models/commit/979df5c854599e8980e1aeae905ce83abf1812c7))
* temporarily removing zeide_2002 response description to avoid errors in the CRAN version of allometric ([cce52a0](https://github.com/allometric/models/commit/cce52a0317ae74fd524358691df89fa431945a02))


* Forcing breaking change ([45fc7c3](https://github.com/allometric/models/commit/45fc7c3e65f0d548b52c23796cc4638f21a5b1b7))


### Features

* adding cochran_1979b ([53020b2](https://github.com/allometric/models/commit/53020b2ed644787e4d1aeb512d104419123c89ca))
* adding mcardle_1961, closes [#25](https://github.com/allometric/models/issues/25) ([a29a093](https://github.com/allometric/models/commit/a29a0932064c032aee6d299d873ccc7b8cd0da0a))
* **models:** added zeide_2002, closes [#18](https://github.com/allometric/models/issues/18) ([b2f305c](https://github.com/allometric/models/commit/b2f305cd1d6f42a395c7e1c0c0abc2085b9ade6c))


### BREAKING CHANGES

* commit
* Updating models to use taxa field

## [1.1.2](https://github.com/allometric/models/compare/v1.1.1...v1.1.2) (2023-09-07)


### Bug Fixes

* changing action branch of allometric to master ([e811129](https://github.com/allometric/models/commit/e8111290910d3860e5fba77ae7229c66ecab30a0))
* resolving error in poudel_2019 with ponderosa pine and subalpine fir biomass models ([7adeb6e](https://github.com/allometric/models/commit/7adeb6e77b7840432f434938ed74812933b93039))

## [1.1.1](https://github.com/allometric/models/compare/v1.1.0...v1.1.1) (2023-08-31)


### Bug Fixes

* adding DOIs to all publications that have them, closes [#16](https://github.com/allometric/models/issues/16) ([0f2b585](https://github.com/allometric/models/commit/0f2b585e0d0afb996dd61f9af0727a0f97f495bc))
* installing instead of loading allometric, which should resolve dependency issues in the test-model-install action ([65b4fcd](https://github.com/allometric/models/commit/65b4fcd42217b9c953c7e5965eda4cc8c4c96334))

# [1.1.0](https://github.com/allometric/models/compare/v1.0.1...v1.1.0) (2023-08-17)


### Features

* **models:** added paine_1982 and hann_1997 ([05cf73a](https://github.com/allometric/models/commit/05cf73a2ade1e7c6a10fee4357e005627cad3a00))

## [1.0.1](https://github.com/allometric/models/compare/v1.0.0...v1.0.1) (2023-08-17)


### Bug Fixes

* adding node package information ([437b191](https://github.com/allometric/models/commit/437b1918687e59fd1362a5b88967d4549ae50b5a))

# 1.0.0 (2023-08-13)


### Features

* initializing with allometric 1.2.0 models ([f85c8f0](https://github.com/allometric/models/commit/f85c8f017308bb5ee991fe0ba21df4b7a124cfad))
