ci
==

A full continious integration stack ready to use in less than 15 minutes.

Using [vagrant](http://www.vagrantup.com/downloads.html) you'll have a VM running [Jenkins](http://jenkins-ci.org/), [SonarQube](http://www.sonarqube.org/) and an instance of [GitLab](http://gitlab.org/) straight away.

How
==

After installing vagrant, simply run the two following commands:

```
git clone https://github.com/swcc/ci
```

```
pushd ci/ && vagrant up && popd
```

Now just browse ```http://ci.swcc.dev/``` with your favorite browser

- GitLab : ```http://ci.swcc.dev/``` Admin credentials __admin@local.host__/__5iveL!fe__
- Jenkins : ```http://ci.swcc.dev:8080/``` 
- Sonar : ```http://ci.swcc.dev:9000/``` Admin credentials __admin__/__admin__

Todo
==

- Add SonarQube Runner
- Add Jenkins Plugins
- Inter-connect all for easy project creation

Contribute
==

The goal of this repository is to have the perfect development environment in minutes when starting new projects.

If you'd like to contribute here's what you can do:

* Write an idea to integrate [here](https://github.com/swcc/ci/issues)
* Code a new feature. Fork, Branch, Pull request..
* Promote the repo to your friends and collegues. Talk about it, share it and use it!
* Eat an Oreo. Because that's always a good thing to do
* Help someone in need. I'm sure you'll find someone to help
