from invoke import task, run
from fabric import Connection


@task
def deploy(c, target):
    remote = Connection(target)

    run("GOOS=linux GOARCH=amd64 go build -o isucondition")
    print("Build success")

    remote.put('isucondition', remote='/tmp/isucondition')
    remote.sudo('mv /tmp/isucondition /home/isucon/webapp/go')
    print("Deploy success")

    remote.sudo('systemctl restart isucondition.go.service')
    print("Restart server")
