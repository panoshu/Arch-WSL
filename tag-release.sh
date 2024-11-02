#!/bin/bash

tagname=$(date +%Y%m%d-%H%M)
git tag -a ${tagname} -m "${tagname}"
git push origin ${tagname}
