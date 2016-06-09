<h1>Pentaho-EE-BA</H2>
Dockerized implementation of Pentaho business analytics 6.0.1.2 Enterprise Edition.  This configuration uses the 'archive' mode of installation. Since Pentaho does not provide public links for it's enterprise downloads, and we do not supply them, this image will not run without links to your archive packages.

<H2>To Run:</H2>
<ul>
  <li>Clone this repository or using a new Dockerfile, source it with the FROM command.</li>
  <li>Set your enterprise file download location in the Dockerfile starting at 'ENV pkg-biserver-ee=.</li>
  <li>Build the docker image for this and pentaho-db</li>
  <li>Run pentaho-ee-ba: docker run -d --name pentaho-ee-ba -p 8080:8080 -e Tier=TEST -e PGUSER=postgresadm -e PGPWD=YourPasswordHere -e PGHOST=pentaho-db -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db:pentaho-db -v /docker/mounts/pentaho-ee-ba/opt/pentaho:/opt/pentaho pentaho-ee-ba:targetversion &</li>
</ul>