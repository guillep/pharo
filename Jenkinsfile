stage ("Checkout") {
    node('osx') {
        git "https://github.com/pharo-project/pharo.git"
        sh "ls"
        stash includes: 'bootstrap/scripts/bootstrap.sh', name: 'stashName'
        cleanWs()
    }
}

stage ("Bootstrap") {
    node('osx') {
        unstash "stashName"
        sh "ls"
        cleanWs()
    }
}

stage ("Test") {
    // labels for Jenkins node types we will build on
    def labels = ['osx', 'windows']
    def builders = [:]
    for (x in labels) {
        // Need to bind the label variable before the closure - can't do 'for (label in labels)'
        def label = x
        builders[label] = {
            node(label) {
                unstash "stashName"
                sh "ls"
            }
        }
    }
    parallel builders
}