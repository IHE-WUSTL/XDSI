mvn install:install-file -Dfile /Users/Kelsey/Projects/IHE/XDSI/git/erl-ihe-xdsi/src/main/reference/dcm4che-core-3.3.7.jar -DgroupId=org.dcm4che -DartifactId=dcm4che-core -Dversion=3.3.7 -Dpackaging=jar -DgeneratePom=true


mvn install:install-file -Dfile=/Users/Kelsey/Projects/IHE/XDSI/git/erl-ihe-xdsi/src/main/reference/dcm4che-core-3.3.7.jar -DgroupId=org.dcm4che -DartifactId=dcm4che-core -Dversion=3.3.7 -Dpackaging=jar

mvn install:install-file -Dfile=/Users/Kelsey/Projects/IHE/XDSI/git/erl-ihe-xdsi/src/main/reference/dcm4che-tool-common-3.3.7.jar -DgroupId=org.dcm4che.tool -DartifactId=dcm4che-tool -Dversion=3.3.7 -Dpackaging=jar

mvn install:install-file -Dfile=/Users/Kelsey/Projects/IHE/XDSI/git/erl-ihe-xdsi/src/main/reference/dcm4che-3.3.7-javadoc.jar -DgroupId=org.dcm4che -DartifactId=dcm4che-core -Dversion=3.3.7 -Dpackaging=jar -Dclassifier=javadoc




mvn install:install-file -Dfile=/Users/Kelsey/Projects/IHE/XDStar/XDStar-modules/XDStarCommon-ejb/target/XDStarCommon-ejb.jar -DgroupId=net.ihe.gazelle.simulators -DartifactId=simulator-common-ejb  -Dversion=1.0.9-SNAPSHOT -Dpackaging=ejb  
mvn install:install-file -Dfile=/Users/Kelsey/Projects/IHE/XDStar/XDStar-modules/target/XDStar-modules-tests.jar -DgroupId=net.ihe.gazelle.xdstar.modules -DartifactId=XDStar-modules  -Dversion=1.0.9-SNAPSHOT  -Dpackaging=jar



mvn install:install-file -Dfile=/Users/Kelsey/Projects/IHE/XDStar/XDStar-modules/target/XDStar-modules-tests.jar -DgroupId=net.ihe.gazelle.test -DartifactId=XDStar-modules  -Dversion=1.0.9-SNAPSHOT  -Dpackaging=jar -DgeneratePom=true
	    <dependency>
			<artifactId>XDStar-modules</artifactId>
			<groupId>net.ihe.gazelle.test</groupId>
			<version>1.0.9-SNAPSHOT</version>
	    </dependency>


mvn install:install-file -Dfile=/Users/Kelsey/Projects/IHE/XDStar/XDStar-modules/XDStarCommon-ejb/target/XDStarCommon-ejb.jar -DgroupId=net.ihe.gazelle.simulators -DartifactId=XDStar-modules  -Dversion=1.0.9-SNAPSHOT -Dpackaging=jar -DgeneratePom=true
	    <dependency>
			<artifactId>XDStar-modules</artifactId>
			<groupId>net.ihe.gazelle.simulators</groupId>
			<version>1.0.9-SNAPSHOT</version>
	    </dependency>




mvn install:install-file -Dfile=/Users/Kelsey/Projects/IHE/XDStar/XDStar-modules/XDRSRCSimulator-ejb/target/XDRSRCSimulator-ejb.jar -DgroupId=net.ihe.gazelle.xdstar.xdrsrc -DartifactId=XDStar-modules -Dversion=1.0.9-SNAPSHOT  -Dpackaging=jar -DgeneratePom=true
	    <dependency>
			<artifactId>XDStar-modules</artifactId>
			<groupId>net.ihe.gazelle.xdstar.xdrsrc</groupId>
			<version>1.0.9-SNAPSHOT</version>
	    </dependency>



mvn install:install-file -Dfile=/Users/Kelsey/Projects/IHE/XDStar/XDStar-modules/XDSImaging-ejb/target/XDSImaging-ejb.jar -DgroupId=net.ihe.gazelle.xdstar.modules -DartifactId=XDStar-modules -Dversion=1.0.9-SNAPSHOT  -Dpackaging=jar -DgeneratePom=true
	    <dependency>
	       <artifactId>XDStar-modules</artifactId>
	        <groupId>net.ihe.gazelle.xdstar.modules</groupId>
	        <version>1.0.9-SNAPSHOT</version>
	    </dependency>

