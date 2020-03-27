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
}
