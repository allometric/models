# models

[![codecov](https://codecov.io/github/allometric/models/branch/mongo_upsert/graph/badge.svg?token=XHS9EGNX27)](https://codecov.io/github/allometric/models)

This repository stores allometric models used in
[`allometric`](https://github.com/allometric), which is a family of software
packages that makes allometric models used in forest monitoring more transparent
and readily availale to end users. Because there are thousands of allometric
models in existence, a separate repository is needed to store and track their
development. This repository is used for this purpose.

In addition to storing R representations of models, `models` implements
infrastructure that converts the R representation into JSON, which is
subsequently stored in a backend Mongo database, which powers our API
(forthcoming) and our interactive web application (forthcoming).

In a sense `models` is the most upstream part of `allometric`:

```
models -> mongo database -> API -> allometric R package
                                -> interactive web application
                                -> other apps
```

Thus, changes made in `models` eventually propagates to all other products.
This allows for rapid fixing and delivery of bugs and quality assurance
improvements.

# How Can I Help?

The primary benefit of `allometric` is an open source platform such that anyone
can contribute allometric models. Here is a list of items you can help with,
ranked from least to most difficult.

1. [Add missing publications as an Issue](https://github.com/allometric/models/issues/new?assignees=brycefrank&labels=add+publication&template=add-models-from-a-publication.md&title=%5BInsert+Author-Date+Citation%5D). 
We always need help *finding publications* to add. If you know of a publication that is missing, feel free to add it as an Issue and we will eventually install the models contained inside.
2.  [Find source material for a publication](https://github.com/allometric/models/labels/missing%20source).
Some publications are missing their original source material. Usually these are very old legacy publications. If you know where a publication might be found, or who to contact, leave a note on any of these issues.
3. [Help us digitize publications](https://github.com/allometric/allometric/issues?q=is%3Aissue+is%3Aopen+label%3A%22digitization+needed%22). 
We always need help *digitizing legacy reports*, at this link you will find a list of reports that need manual digitization. These can be handled by anyone with Excel and a cup of coffee.
4. [Learn how to install and write models](https://allometric.github.io/allometric/articles/installing_a_model.html). 
Motivated users can learn how to install models directly using the package functions and git pull requests. Users comfortable with R and git can handle this task.

Other ideas? Contact bfrank70@gmail.com to help out.

# Versioning (Developers Only)

This repository is versioned separately from `allometric` using
[`semantic-release`](https://github.com/semantic-release/semantic-release),
a Node.js tool that facilitates semantic versioning. This enables a rigid
release framework for new allometric models and modifications therein.

To install the versioning dependencies: `npm install`
To create a release commit: `npx semantic-release --no-ci`

Versioning Philosophy:
  - Breaking releases - Occur only when breaking changes happen to
    `allometric/models`, this might occur do to downstream effects on
    `allometric/allometric` or other software. These should be exceptionally
    rare.
  - Feature releases - Are meant to accommodate batch releases of several
    publications at a time. New publications should be added as `feat`. These
    should occur for every 3-7 new publications.
  - Fix releases - Are meant to accommodate edits to publication files and
    parameters, but not additions. Edits to models should be added as `fix` and
    a new release should be made for each fix.
