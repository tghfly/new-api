pipeline {
   agent any
   environment {
       image_url = "registry.tydic.com"
       project_name = "new-api"
       pod_prefix = "new-api"
       version = sh(script: 'date +%Y%m%d', returnStdout: true).trim()
   }
   stages {
//       stage('pull project') {
//          steps {
//             checkout([$class: 'GitSCM', branches: [[name: 'merge_onehub']], extensions: [], userRemoteConfigs: [[credentialsId: '27f29dcd-b882-4d6b-83ed-06483bf631c3', url: "https://git.tydic.com:11011/TRDC-CSR/cloud/mo/ai/${project_name}.git"]]])
//          }
//       }
      stage('build project') {
         steps {
               sh '''
               make image tag=gx-${version}
               '''
         }
      }
      stage('publish image') {
         steps {

withCredentials([usernamePassword(credentialsId: '00a62033-d13b-4b89-a534-dfc8067bb23f', passwordVariable: 'harbor_pass', usernameVariable: 'harbor_user')]) {
    //  sh '''echo ${harbor_pass} |docker login ${imageUrl} -u ${harbor_user} --password-stdin '''
    sh '''
    docker login registry.tydic.com -u ${harbor_user} -p ${harbor_pass}
    echo ${image_url}/ai-studio/${project_name}:${version}
    docker push ${image_url}/ai-studio/${project_name}:gx-${version}
    '''
}


         }
      }
	//   stage('update k8s Pod') {
	//   steps {
	//     sh '''
	//     kubectl --kubeconfig=/root/.jenkins/.kube/config get pods -A |grep ${pod_prefix} |awk '{print "kubectl --kubeconfig=/root/.jenkins/.kube/config delete pods -n " $1 " " $2}' |sh
	// 	'''
	//   }
	//   }
   }
}
