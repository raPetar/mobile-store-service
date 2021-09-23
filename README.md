# mobile-store-service

This is an WEB API for the [mobile-app-store](https://github.com/raPetar/mobile-store-service/products) project, developed in .net core 3.1

## Try out the [DEMO](https://mobile-app-store-service.herokuapp.com) here

## Installation
1. Download and open the project using Visual Studio
2. Under Solution name, in the DBInitScript there is an sql file called "MobileStoreInit"
3. Execute the sql file in SQL Server to create the sample database
4. Copy the server name of the sql instance you are currently on (on the left side, right click the server name in Object Explorer => properites => copy server name)
5. Replace the server name in appsettings.json for the "DefaultConnection"
6. Run the project using "ShopService" instead of IIS


URL Params: 
* /products
* /products/{id}
* /products/search/{keyword}
* /reviews/{id}
* /questions/{id}
* /category

**If using postman agent on local machine you can send additonal params from the body as JSON**
* POST param {url}/users/login 
   
 ```  
 {
    "userName": "admin",
    "password": "1234"
 }
 ```
 * POST param {url}/users/register
 ```
 {
    "userName":"admin",
    "firstName":"John",
    "lastName": "Johnsons",    
    "phoneNumber":"12345678",
    "email": "test@test.com",
    "password":"1234"
}
 ```

