# CyberYetiOne
Slack App for submitting ski reports to slack channels for people.

Eats skiers, shits snow.

Shows fridged camera from top.

Massages the overly optimistic ski report and puts it out daily.

- `cyberyetione.rb` - pulls "top of the mountain" picture and posts to slack channel.
- `coolaid.rb` - pulls snow report from Cannon's website and posts to a slack channel.
- `loonaid.rb` - pulls ski report from Loon's website and posts to slack channel

# install
run like this
1. `ruby ./cyberyetione.rb` or `ruby ./coolaid.rb`
2. wait for ruby gem fails from require
3. install gems with `gem install missing_ruby_gem`
4. go to 1

# reads from cyberyeti.config
format should is YAML config for where to post what.
slack_channels is an array of URLs to post to
```
---
:slack_channels:
- 'https://hooks.slack.com/services/AAAAAAAAA/AAAAAAAAA/AAAAA2utdcRn3SFi4RyLeKLY'
- 'https://hooks.slack.com/services/BBBBBBBBB/AAAAAAAAA/AAAAA2utdcRn3SFi4RyLeKLY'
```
