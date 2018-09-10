properties([disableConcurrentBuilds(), pipelineTriggers([githubPush()])])
node {
    stage('Checkout') {

//---------------- Variables/Definitions
    env.WORKSPACE = pwd()
	env.DOTNETPATH = "/mnt/jenkins-home/dotnet-${env.BRANCH_NAME}"
	env.DOTNET = "${env.DOTNETPATH}/dotnet"
	env.DOTNETVERSION = "1.0.0-preview2-003131"
	env.TERRAFORMPATH = "/mnt/jenkins-home/terraform-${env.BRANCH_NAME}"
	env.TERRAFORM ="${env.TERRAFORMPATH}/terraform"
	env.TERRAFORMVERSION = "0.11.7"
	env.TERRAFORMURL = "https://releases.hashicorp.com/terraform/${env.TERRAFORMVERSION}/terraform_${env.TERRAFORMVERSION}_linux_amd64.zip"
	env.YARNPATH = "/mnt/jenkins-home/yarn-${env.BRANCH_NAME}"
	env.YARN ="${env.YARNPATH}/yarn-v1.6.0/bin/yarn"
	env.YARNVERSION = "1.6.0"
	env.YARNURL = "https://yarnpkg.com/latest.tar.gz"
	env.NODEPATH ="/mnt/jenkins-home/node-${env.BRANCH_NAME}"
	env.TF_PLAN_FILE = "TF-${env.BRANCH_NAME}-plan.out"
	env.TF_COMMON_PLAN_FILE = "TF-common-plan.out"
	env.NODEVERSION = "v8.11.2"
    env.NODE = "${env.NODEPATH}/node-${env.NODEVERSION}-linux-x64/bin/node"
	env.NPM  = "${env.NODEPATH}/node-${env.NODEVERSION}-linux-x64/bin/npm"
    env.NGPATH = "/mnt/jenkins-home/ng-${env.BRANCH_NAME}"
	env.NG = "${env.NGPATH}/lib/node_modules/@angular/cli/bin/ng"
	env.NGVERSION = "@angular/cli: 1.0.0"
	env.AWSPATH = "/mnt/jenkins-home/aws-${env.BRANCH_NAME}"
	env.AWS = "${env.AWSPATH}/bin/aws"
	env.AWSREGION = "eu-west-2"
	env.AWSVERSION = "11529"
	env.AWSURL = "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
	env.MySQLPATH = "/mnt/jenkins-home/mysql-${env.BRANCH_NAME}"
	env.MySQL = "${env.MySQLPATH}/mysql"
	env.MySQLVERSION = "5.6.35"
	env.PATH = "${env.NODEPATH}/node-${env.NODEVERSION}-linux-x64/bin/:${env.DOTNETPATH}:${env.PATH}" 
	env.FRONTENDHASHFILE = "/mnt/jenkins-home/${env.BRANCH_NAME}-frontend-hash"
	env.DOTNETHASHFILE = "/mnt/jenkins-home/${env.BRANCH_NAME}-dotnet-code-hash"
    env.DOTNET_CONTAINER_GITHASH_FILE = "/mnt/jenkins-home/${env.BRANCH_NAME}-dotnet-container-githash"
	env.FRONTEND_CONTAINER_GITHASH_FILE = "/mnt/jenkins-home/${env.BRANCH_NAME}-frontend-container-githash"
    env.DOTNETBINARYSTASH = "/mnt/jenkins-home/${env.BRANCH_NAME}-dotnet-binary-stash/"
    env.DOTNETPUBLISHSTASH = "/mnt/jenkins-home/${env.BRANCH_NAME}-dotnet-publish-stash/"
	env.ANGULARAPPSTASH = "/mnt/jenkins-home/${env.BRANCH_NAME}-angular-app-stash/"
    env.ANGULARAPPHASHFILE = "/mnt/jenkins-home/${env.BRANCH_NAME}-angular-app-code-hash"
	env.ANGULARPUBLICHASHFILE = "/mnt/jenkins-home/${env.BRANCH_NAME}-angular-public-code-hash"
	env.REACTAPPSTASH = "/mnt/jenkins-home/${env.BRANCH_NAME}-react-app-stash/"
    env.REACTAPPHASHFILE = "/mnt/jenkins-home/${env.BRANCH_NAME}-react-app-code-hash"
	env.REACTPUBLICHASHFILE = "/mnt/jenkins-home/${env.BRANCH_NAME}-react-public-code-hash"
    env.PUBLIC_SSH_DEPLOY_KEY_ID = readFile('/mnt/jenkins-home/public-repo-ssh-deploy-key-id').trim()
	env.PRIVATE_SSH_DEPLOY_KEY_ID = readFile('/mnt/jenkins-home/private-repo-ssh-deploy-key-id').trim()
    env.STATE_S3_BUCKET_FILE = "/mnt/jenkins-home/state-s3-bucket"
	env.STATE_S3_BUCKET = readFile(env.STATE_S3_BUCKET_FILE).trim()


//	env.APP_S3_BUCKET_FILE = "/tmp/${env.BRANCH_NAME}-app-s3-bucket"
//    env.PUBLIC_S3_BUCKET_FILE = "/tmp/${env.BRANCH_NAME}-public-s3-bucket"


//-----------------Checkout
//        gitClean()
    slackSend "Build Started - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
    sh "rm -rf *"
    sh "rm -rf .git"
    checkout scm
	sh "git rev-parse --short HEAD | tee shorthash"
	env.GITSHORTHASH = readFile('shorthash').trim()
	echo "Checkout complete... extracting environment name from tfvars"

   }
   stage('Tools') {
   // Output build container environment
   sh "cat /etc/*-release"
   // Check docker works
   sh "docker -v"

   install_aws()
   install_mysql()
   install_node()
   install_angular()
   install_yarn()
   install_terraform()
   install_dotnet()
   }
   
}

void gitClean() {
    timeout(time: 300, unit: 'SECONDS') {
        if (fileExists('.git')) {
            echo 'Found Git repository: using Git to clean the tree.'
            // The sequence of reset --hard and clean -fdx first
            // in the root and then using submodule foreach
            // is based on how the Jenkins Git SCM clean before checkout
            // feature works.
            sh 'git reset --hard'
            // Note: -e is necessary to exclude the temp directory
            // .jenkins-XXXXX in the workspace where Pipeline puts the
            // batch file for the 'bat' command.
            // TODO: don't delete .venv
            sh 'git clean -ffdx -e ".venv/ .jenkins-*/"'
            sh 'git submodule foreach --recursive git reset --hard'
            sh 'git submodule foreach --recursive git clean -ffdx'
        }
        else
        {
            echo 'No Git repository found: using deleteDir() to wipe clean'
            deleteDir()
        }
    }
}

String commit_sha() {
    sh 'git rev-parse --short HEAD | tee .out'
    def commit_sha = readFile('.out').trim()
    commit_sha ? commit_sha : "unknown"
}

String branch_name_short() {
    sh 'echo $BRANCH_NAME | head -c3 | tee .out'
    def branch_name_short = readFile('.out').trim()
    branch_name_short ? branch_name_short : "unknown"
}

void install_aws() {
	
   //-----------------Check AWS version and install
   if (fileExists("${env.AWS}")) {
	    sh "${env.AWS} --version  2>&1 > /dev/null | sed \'s/ .*//\' | tr -d \'/.A-Za-z\\-\' | tee version"
	    env.AWSCURRENTVERSION = readFile('version').trim()
		} else {
        env.AWSCURRENTVERSION = "not installed"
		}
	if ("${env.AWSCURRENTVERSION}" < "${env.AWSVERSION}") {
        echo "Installing AWS CLI..."
		sh "rm -rf ${env.AWSPATH}; mkdir -p ${env.AWSPATH}"
		sh "wget -O awscli-bundle.zip ${env.AWSURL}"
        sh "unzip awscli-bundle.zip"
        sh "./awscli-bundle/install -i ${env.AWSPATH}"
		}
	if (fileExists("${env.AWS}")) {
	    sh "${env.AWS} --version  2>&1 > /dev/null | sed \'s/ .*//\' | tr -d \'/.A-Za-z\\-\' | tee version"
	    env.AWSCURRENTVERSION = readFile('version').trim()
		echo "AWS CLI version: ${env.AWSCURRENTVERSION}"
		} else {
        currentBuild.result = 'FAILURE'
		echo "AWS CLI installation has failed!"
		}
	if ("${env.AWSCURRENTVERSION}" < "${env.AWSVERSION}") {
	    currentBuild.result = 'FAILURE'
	    error "AWS CLI installation version ${env.AWSCURRENTVERSION} does not match required version of ${env.AWSVERSION}!"
	    
	}
}
void install_mysql() {
	//-----------------Check MySQL version and install

  if (fileExists("${env.MySQL}")) {
	    sh "${env.MySQL} --version | grep -E -o '[0-9]+\\.[0-9]+\\.[0-9]+' | tee version"
	    env.MySQLCURRENTVERSION = readFile('version').trim()
		} else {
        env.MySQLCURRENTVERSION = "not installed"
		}
	if ("${env.MySQLCURRENTVERSION}" != "${env.MySQLVERSION}") {
        echo "Installing MySQL Client..."
		sh "rm -rf ${env.MySQLPATH}; mkdir -p ${env.MySQLPATH}"
		sh "wget -O mysql-installer.tar.gz https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz"
        sh "tar -xvzf mysql-installer.tar.gz --no-anchored --strip-components 2 -C ${env.MySQLPATH} bin/mysql "
		}
	if (fileExists("${env.MySQL}")) {
	    sh "${env.MySQL} --version | grep -E -o '[0-9]+\\.[0-9]+\\.[0-9]+' | tee version"
	    env.MySQLCURRENTVERSION = readFile('version').trim()
		echo "MySQL version: ${env.MySQLCURRENTVERSION}"
		} else {
        currentBuild.result = 'FAILURE'
		echo "MySQL installation has failed!"
		}
	if ("${env.MySQLCURRENTVERSION}" != "${env.MySQLVERSION}") {
	    currentBuild.result = 'FAILURE'
	    error "MySQL installation version ${env.MySQLCURRENTVERSION} does not match required version of ${env.MySQLVERSION}!"
	    
	}
}

void install_node() {
	
//-----------------Check Node version and install
    if (fileExists("${env.NODE}")) {
	    sh "${env.NODE} --version >version"
	    env.NODECURRENTVERSION = readFile('version').trim()
		} else {
        env.NODECURRENTVERSION = "not installed"
		}
	if ("${env.NODECURRENTVERSION}" != "${env.NODEVERSION}") {
        echo "Installing Node and NPM..."
        sh "rm -rf ${env.NODEPATH}; mkdir -p ${env.NODEPATH}"
	    sh "wget -O node.tar.xz https://nodejs.org/dist/v8.11.2/node-v8.11.2-linux-x64.tar.xz"
	    sh "tar -xvf node.tar.xz -C ${env.NODEPATH}"
        }
	if (fileExists("${env.NODE}")) {
	    sh "${env.NODE} --version >version"
	    env.NODECURRENTVERSION = readFile('version').trim()
		echo "Node version: ${env.NODECURRENTVERSION}"
		} else {
        currentBuild.result = 'FAILURE'
		echo "Node installation has failed!"
		}
	if ("${env.NODECURRENTVERSION}" != "${env.NODEVERSION}") {
	    currentBuild.result = 'FAILURE'
	    error "Node installation version ${env.NODECURRENTVERSION} does not match required version of ${env.NODEVERSION}!"
	   
	}
}

void install_angular() {
	
//----------- Check version of angular cli and install
     if (fileExists("${env.NG}")) { 
	    sh "${env.NG} --version | grep @angular/cli | tee version"
	    env.NGCURRENTVERSION = readFile('version').trim()
		} else {
        env.NGCURRENTVERSION = "not installed"
		}
	if ("${env.NGCURRENTVERSION}" != "${env.NGVERSION}") {
        echo "Installing Angular CLI..."
        sh "rm -rf ${env.NGPATH}; mkdir -p ${env.NGPATH}"
	    sh "${env.NPM} install --prefix ${env.NGPATH} @angular/cli@1.0.0 -g"
        }
	if (fileExists("${env.NG}")) {
	    sh "${env.NG} --version | grep @angular/cli >version"
	    env.NGCURRENTVERSION = readFile('version').trim()
		echo "NG version: ${env.NGCURRENTVERSION}"
		} else {
        currentBuild.result = 'FAILURE'
		echo "NG installation has failed!"
		}
	if ("${env.NGCURRENTVERSION}" != "${env.NGVERSION}") {
	    currentBuild.result = 'FAILURE'
	    error "NG installation version ${env.NGCURRENTVERSION} does not match required version of ${env.NGVERSION}!"
	    
        }
}

void install_yarn() {
	
		//----------- Check version of yarn and install
     if (fileExists("${env.YARN}")) { 
	    sh "${env.YARN} --version | tee version"
	    env.YARNCURRENTVERSION = readFile('version').trim()
		} else {
        env.YARNCURRENTVERSION = "not installed"
		}
	if ("${env.YARNCURRENTVERSION}" != "${env.YARNVERSION}") {
        echo "Installing Yarn..."
        sh "rm -rf ${env.YARNPATH}; mkdir -p ${env.YARNPATH}"
	    sh "wget -O yarn.tar.gz ${env.YARNURL}"
	    sh "tar -xvzf yarn.tar.gz -C ${env.YARNPATH}"
        }
	if (fileExists("${env.YARN}")) {
	    sh "${env.YARN} --version >version"
	    env.YARNCURRENTVERSION = readFile('version').trim()
		echo "Yarn version: ${env.YARNCURRENTVERSION}"
		} else {
        currentBuild.result = 'FAILURE'
		echo "Yarn installation has failed!"
		}
	if ("${env.YARNCURRENTVERSION}" != "${env.YARNVERSION}") {
	    currentBuild.result = 'FAILURE'
	    error "Yarn installation version ${env.YARNCURRENTVERSION} does not match required version of ${env.YARNVERSION}!"
        }
}


void install_terraform() {
//----------- Check version of terraform and install
     if (fileExists("${env.TERRAFORM}")) {
	    sh "${env.TERRAFORM} --version | grep -E -o 'v[0-9\\.]+' | tee version"
	    env.TERRAFORMCURRENTVERSION = readFile('version').trim()
		} else {
        env.TERRAFORMCURRENTVERSION = "not installed"
		}
	if ("${env.TERRAFORMCURRENTVERSION}" != "v${env.TERRAFORMVERSION}") {
        echo "Installing Terraform because current version is ${env.TERRAFORMCURRENTVERSION}...."
        sh "rm -rf ${env.TERRAFORMPATH}; mkdir -p ${env.TERRAFORMPATH}"
	    sh "wget -O terraform.zip ${env.TERRAFORMURL}"
	    sh "unzip -d ${env.TERRAFORMPATH} terraform.zip"
        }
	if (fileExists("${env.TERRAFORM}")) {
	    sh "${env.TERRAFORM} --version | grep -E -o 'v[0-9\\.]+' | tee version"
 		env.TERRAFORMCURRENTVERSION = readFile('version').trim()
		} else {
        currentBuild.result = 'FAILURE'
		error "Terraform installation has failed!"
		}
	if ("${env.TERRAFORMCURRENTVERSION}" != "v${env.TERRAFORMVERSION}") {
	    currentBuild.result = 'FAILURE'
	    error "Terraform installation version ${env.TERRAFORMCURRENTVERSION} does not match required version of v${env.TERRAFORMVERSION}!"
	    
        }
}

void install_dotnet() {
	//----------- Dotnet install

	if (fileExists("${env.DOTNET}")) {
	    sh "${env.DOTNET} --version | tee version"
		env.DOTNETCURRENTVERSION = readFile('version').trim()
		} else {
		sh "echo NOT INSTALLED >version"
		}
		
	if ("${env.DOTNETCURRENTVERSION}" != "${env.DOTNETVERSION}") {
	    echo "Installing .net CLI"
	    sh "rm -rf ${env.DOTNETPATH}; mkdir -p ${env.DOTNETPATH}"
		// install sdk last
	    sh "wget -O dotnetsdk.tar.gz https://go.microsoft.com/fwlink/?LinkID=827530"
	    sh "wget -O dotnet105.tar.gz https://download.microsoft.com/download/2/4/A/24A06858-E8AC-469B-8AE6-D0CEC9BA982A/dotnet-debian-x64.1.0.5.tar.gz"
        sh "tar -xvf dotnet105.tar.gz -C ${env.DOTNETPATH}"
		sh "tar -xvf dotnetsdk.tar.gz -C ${env.DOTNETPATH}"
	    
		//output dotnet version
  	    sh "${env.DOTNET} --version"
	    }
	
  }

  void docker_push(String serviceName,String tag) {
	  sh "docker tag  ${env.ENV_NAME}-${serviceName} ${env.ecrAwsAccount}.dkr.ecr.${env.AWSREGION}.amazonaws.com/${env.ENV_NAME}/${serviceName}:${tag}" 	
	  sh "docker push ${env.ecrAwsAccount}.dkr.ecr.${env.AWSREGION}.amazonaws.com/${env.ENV_NAME}/${serviceName}:${tag}" 
  }

void write_dynamic_tfvars(String tfvarsFile) {
	sh "echo dotnet-container-githash=\\\"${env.DOTNET_CONTAINER_GITHASH}\\\" | tee ${tfvarsFile}"
	sh "echo frontend-container-githash=\\\"${env.FRONTEND_CONTAINER_GITHASH}\\\" | tee -a ${tfvarsFile}"
	sh "echo allowed-account-ids=\\\"${env.AWSACCOUNT}\\\" | tee -a ${tfvarsFile}"
	sh "echo build-account-id=\\\"${env.buildAwsAccount}\\\" | tee -a ${tfvarsFile}"
	sh "echo ecr-aws-account-id=\\\"${env.ecrAwsAccount}\\\" | tee -a ${tfvarsFile}"
	sh "echo aws-account-id=\\\"${env.AWSACCOUNT}\\\" | tee -a ${tfvarsFile}"
}

void write_aws_config(String awsConfigFile) {
	env.AWS_CONFIG_FILE=awsConfigFile
//	sh "echo [default] | tee ${awsConfigFile}"
	sh "echo [profile assumerole] | tee -a ${awsConfigFile}"
	sh "echo role_arn=${env.ROLE_TO_ASSUME} | tee -a ${awsConfigFile}"
	sh "echo credential_source = Ec2InstanceMetadata | tee -a ${awsConfigFile}"
}
