# INFRAESTRUCTURA COMO CÓDIGO CON TERRAFORM + MULTI-AMBIENTE




En este repositorio encontrarás un proyecto en el cual se despliega  una infraestructura usando código en aws, además de ser multi Ambiente tiene una mejor automatización ya que puedo lanzar ambiente por ambiente.




Aqui hacemos una explicación detallada de como desplegar el proyecto de forma personalizada, esto debido a que al ser modular el código pueda ser adaptado para los interés de una persona cualquiera


## Asi funciona:




![Logo](https://miro.medium.com/1*JZs9fYRdlt0YTMhf20_J6A.png)




## Se necesita tener




- Descargar terraform en la página oficial de terraform [Terraform.com](https://developer.hashicorp.com/terraform/install) descargar el ideal pra su sistema operativo.
- Configurar y descargar la  AWS ACL  para conocer cmo se configura puede ver el siguiente tutorial: [Cómo configurar la AWS CLI](https://developer.hashicorp.com/terraform/install).
- Un editor de codigo
- Un usuario en IAM de aws con  secret key & access key
- [instalar git](https://git-scm.com/book/es/v2/Inicio---Sobre-el-Control-de-Versiones-Instalaci%C3%B3n-de-Git) 




## 1. Instalar aws CLi
Puede descargar la version mas reciente de  [AWS Command Line Interface (AWS CLI)](https://docs.aws.amazon.com/es_es/cli/latest/userguide/getting-started-install.html).


Puede verificar la instalación o ver que version tiene con este comando
```bash
 aws --version
```
Después hay que crear un usuario en aws en IAM. En grupos de permisos pedirá un nombre y en descripción es importante que se  seleccione  provides **full access aws service**, porque tiene la mayoría de los permisos necesarios para el proyecto.


Después hay que entrar en credenciales de seguridad y crear un access ACCESS_KEY_ID, y en use case seleccionar **command line Interface (CLI)** guardar el ACCESS_KEY_ID y SECRET_ACCESS_KEY en un lugar privado,  para ahora configurar los accesos en terminal:


```bash
 aws configure
```
Aquí luego pedirá el ACCESS_KEY_ID y SECRET_ACCESS_KEY despues no s pedira el región a utilizar, y listo el computador tendrá permisos para desplegar todo tipo de servicios en aws.


Antes de desplegar código hay que configurar un S3 en aws esto debido a que cuando terraform se ejecute creará un archivo terraform.tfstate el cual guardara los estados del proyecto y este estaría alojado en aws no de forma local.


Desde terminal  se puede lanzar el bucket  de S3 que se había mencionado.


```bash
 aws S3api create-bucket "Nombre unico en el mundo" --poner region de preferencia
```
Para mayor seguridad podemos cifrar el bucket para tener mas seguridad si tenemos contenido delicado, crear un encryption.txt en el usuario de del pc con este código.


```bash
{
 "Rules": [
   {
     "ApplyServerSideEncryptionByDefault": {
       "SSEAlgorithm": "AES256"
     }
   }
 ]
}
```
Luego en terminal se ejecuta:


```bash
aws s3api put-bucket-encryption `


      --bucket **terraform-bucket-alcidez** `


     --server-side-encryption-configuration file://encryption.json
```


verificar que este bien el cifrado en aws se puede encontrar el S3 creado.


```bash
aws s3api get-bucket-encryption --bucket terraform-bucket-alcidez
```
Además para evitar que varias personas modifiquen el mismo ambiente a la vez se crea una table Dynamo


```bash


aws dynamodb create-table `


      --table-name **Nombre de la tabla creada en aws** `


      --attribute-definitions AttributeName=LockID,AttributeType=S `


      --key-schema AttributeName=LockID,KeyType=HASH `


      --billing-mode PAY\_PER\_REQUEST `


      --region us-east-1
```
Importante notar que en  la infraestructura se pone el nombre de la dynamon table en el bucked.tf y en variables.tf y resto de archivos que lo necesiten poner la región con la que se hicieron los previos ajustes que se hace para cualquier proyecto de este  tipo.


Hay que decir dónde se va a guardar los archivos que se van a leer en la s3 previamente desplegada


**leer base de datos:**
```bash
aws ssm put-parameter --name "/app/dev/db_password" --value "MiPasswordSegura123!" --type "SecureString" --overwrite
aws ssm put-parameter --name "/app/prod/db_password" --value "MiPasswordSuperSegura123!" --type "SecureString" --overwrite
aws ssm put-parameter --name "/app/staging/db_password" --value "MiPasswordHiperSegura123!" --type "SecureString" --overwrite
```


Ahora desde la terminal en la ruta del archivo en el editor de código se crean los workspace que en donde se ejecutarán los ambientes.


**creación de workspace:**
```bash
terraform workspace new dev


terraform workspace new staging


terraform workspace new prod
```
**selección de workspace:**
```bash
terraform workspace select aquí el nombre de workspace a seleccionar
```


Después de llegar aquí desde el el computador se puede hacer un despliegue de entornos de forma separada puesto que debería estar todo configurado para ya crear la infraestructura y verla en aws.


En terminal desde la dirección de la carpeta del archivo se puede iniciar con pruebas.


```bash
terraform init     # Esto inicializa el código creara una carpeta  .terraform
```
Para ver que se va a crear antes de desplegar la infraestructura se hace.
```bash
terraform plan -var-file="env/(ambiente a desplegar dev,pord, staging).tfvars"
```
Para desplegar la infraestructura se copia
```bash
terraform apply -var-file="env/(ambiente a desplegar dev,pord, staging).tfvars"
```
Dirá si se está seguro de desplegar el código. Yes or not enter y desplegará un ambiente.
## 2. Subir el proyecto a un repositorio de github




- [tutorial como subir mi proyecto de github](https://www.youtube.com/watch?v=nyJAI0DBxhs).


- Crear branchs, por default existe un branch llamado main, hay que crear dos más uno llamado staging y otro dev, no se crea uno llamado prod en este caso porque el workflows está hecho para usar prod en main, si alguien le parece mejor tener una branch llamada prod lo que puede hacer es hacer una  rama llamada prod y  en el workflows mian.yml cambiar los nombres de main  por prod.




/cada vez que se hace run workflows empieza a correr la infraestructura.








## 3. Clonar el repositorio de github en local




- [tutorial como clonar un repositorio](https://www.youtube.com/watch?v=9WG-DefyNk4).


Si se clona una versión en local  desde un editor de código habría que hacer las siguientes configuraciones.


```bash
git checkout (nombre para la rama dev,main o staging)
```
```bash
git branch -r      # muestra todas las ramas que existen
```
```bash
git checkout (nombre para la rama dev,main o staging)  #verificar si se está en la rama correcta,
```
En el editor de código hay que crear las mismas ramas que están en remoto, así como los workspace.


# Cómo lanzar la arquitectura a la  nube




Cuando estén listos los cambios en el editor para subir  github primero hacemos en la terminal del proyecto


```bash
 git status
```
Mostrará si hay cambios pendientes, si hay pedirá que se guarden, ejecutamos este comando que añadirá todos los cambios y subirlos.




```bash
 git add .
 git commit -m "Actualización"
```
Solo dirá que todo está actualizado. Cuando se realicen cambios en github y los queramos traer al pc para que no existan conflictos con las versiones del repositorio, se ejecuta de forma local  dependiendo en qué ambiente se hicieron cambios.


```bash
 git pull origin dev
 git pull origin main
 git pull origin staging
```
Ejecuta cada ambiente según el brunch que se quiera desplegar, así como los anteriores comandos puesto que  el control de versiones de ramas hay que guardar los cambios en el ambiente correspondiente.


```bash
 git push origin main  #esto se hace en el branch de main
```
```bash
 git push origin dev  #esto se hace en el branch de dev
```
```bash
 git push origin staging    #esto se hace en el branch destaging
```






## 4.En github configurar la security key, access key y workflows




Buscar en setting del repositorio ir a la pestaña de secrets and variables que está en el panel izquierdo y seleccionamos **actions**




Aquí en la pestaña secrets se crea un  nuevo repositorio secreto: new repository secret, se crean dos nuevos secretos una será **AWS_ACCESS_KEY_ID** con la respectiva AWS_ACCESS_KEY_ID que encontramos en aws, el segundo secreto es **AWS_SECRET_ACCESS_KEY** y colocar la respectiva secret key creada, con esto hecho creamos el workflows en la la pestaña **actions**  seleccionar crear **workflows** y  poner los respectivos secretos ya creados un ejemplo puede ser el archivo **mina.yml** en la carpeta **.github/workflows**.




Un dato importante es que estos secretos creados no pueden ser transferidos a otros por lo cual se pone como un secreto en github para que nadie que vea el repositorio pueda tener acceso a la llave de acceso.








## Feedback
si tienes un  feedback, puedes enviarlo a rricardo@unal.edu.co o tsernar@unal.edu.co




## 🛠 Skills
Terraform, gtihub...




## Lessons Learned


Mientras construimos este proyecto en cooperación  aprendimos nuevas habilidades y desarrollamos otras, logramos aprender terraform lo cual era una nueva forma de programar con otra orientación y usar herramientas de git. en el proyecto aprendimos sobre la marcha lo cual llevó a muchos ensayos y errores.




##  About we
Rafael Duvan Ricardo Romero:


Thomas Serna Restrepo:




##  Skills
Terraform, gtihub...




## Lessons Learned


Mientras construimos este proyecto en cooperación  aprendimos nuevas habilidades y desarrollamos otras, logramos aprender terraform lo cual era una nueva forma de programar con otro orientación y usar herramientas de git. en el proyecto aprendimos sobre la marcha lo cual llevó a muchos ensayos y errores.






