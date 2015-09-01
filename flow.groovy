node {
    stage 'Build image'
    git 'https://github.com/ContainerSolutions/mesos-local.git' 
    def base = docker.image("containersol/dind:latest");
    base.pull()
    def imageName = "containersol/mesos-local:${env.BUILD_NUMBER}"
    def image = docker.build(imageName)

    stage name: 'Push Image'
        image.push()
        /*  stage 'Test image'
            image.inside() {
            stage 'Execute Test1'
            sh 'echo test'
            }
         */

    stage name: 'Promote Image', concurrency: 1
    // input id: 'Proceed1', message: "Do you want me to promote the image to 'latest' and push?", ok: 'Yes, please do'
    image.push 'latest'
    try{
        // image can be removed otherwise we will have lots of them on the server
        sh 'docker rmi ' + imageName
    } catch (Exception _) {
        echo "no image to remove"
    }
}
