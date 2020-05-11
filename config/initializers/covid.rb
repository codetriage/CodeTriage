# frozen_string_literal: true
# Here is how to add a "COVID-19" related resource to the project
#
# 1) Find the GitHub url of the project such as `https://github.com/nextstrain/ncov`
# 2) Ensure the project is added to CodeTriage, visit https://www.codetriage.com/repos/new and add the repo
# 3) Come back to this file on GitHub and in the COVID_REPOS array (inside the %W{}) add the username and name of the repo
# 4) Save the file in the UI and submit a PR
# 5) Repeat
#
COVID_REPOS = %W{
  nextstrain/ncov
  jcl5m1/ventilator
  CSSEGISandData/COVID-19
  nextstrain/auspice
  nextstrain/augur
  nextstrain/janus
  nextstrain/fauna
  nextstrain/nextstrain.org
  neherlab/covid19_scenarios
  neherlab/covid19_scenarios
  mhdhejazi/CoronaTracker
  ahmadawais/corona-cli
  ushahidi/platform
  ushahidi/ushahidi_web
  HospitalRun/hospitalrun
  HospitalRun/hospitalrun-frontend
  HospitalRun/hospitalrun-server
  learningequality/kolibri
  svs/covid19-supply-chain
  nytimes/covid-19-data
  Leo1690/BtPedalClient
  Leo1690/BtPedalServer
}
