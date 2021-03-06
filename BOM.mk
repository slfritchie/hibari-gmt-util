###----------------------------------------------------------------------
### Copyright (c) 2007-2010 Gemini Mobile Technologies, Inc.  All rights reserved.
### 
### Licensed under the Apache License, Version 2.0 (the "License");
### you may not use this file except in compliance with the License.
### You may obtain a copy of the License at
### 
###     http://www.apache.org/licenses/LICENSE-2.0
### 
### Unless required by applicable law or agreed to in writing, software
### distributed under the License is distributed on an "AS IS" BASIS,
### WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
### See the License for the specific language governing permissions and
### limitations under the License.
###
### File    : BOM.mk
### Purpose :
###----------------------------------------------------------------------

ifeq ($(erl-bom-mk),)
include $(SRCDIR)/$(firstword $(filter src/erl-tools/gmt-bom__%,$(MY_DEPENDS)))/make/erl_bom.mk
endif

$(ME)/.bom_config: $(erl-bom-mk)
	$(erl-bom-config)
	touch $@

$(ME)/.bom_build: $(ME)/.bom_config $(erl-bom-mk)
	$(erl-bom-build)
	touch $@

$(ME)/.bom_install: $(ME)/.bom_build $(erl-bom-mk)
	$(erl-bom-install)
	touch $@

$(ME)/.bom_test: $(ME)/.bom_install $(erl-bom-mk)
	$(erl-bom-test)

$(ME)/.bom_clean: $(erl-bom-mk)
	$(erl-bom-clean)
