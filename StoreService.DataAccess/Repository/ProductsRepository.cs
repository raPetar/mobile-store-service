using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dapper;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using ShopService.DataAccess.Interfaces;
using ShopService.DataAccess.Models;
using ShopService.Models;

namespace ShopService.DataAccess.Repository
{
    public class ProductsRepository : IProducts
    {
        private readonly IConfiguration _configuration;
 

        public ProductsRepository(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task<ProductList> getBrowseProducts(int getNextProducts)
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionString)) {

                connection.Open();
                var result = await connection.QueryAsync<Product>("dbo.RetrieveBrowseProducts @GetNextProducts", new { GetNextProducts = getNextProducts });

                ProductList list = new ProductList();
                list.productList = new List<Product>();


              
                foreach (var p in result)
                {
                    Product product = new Product();
                    product.ProductID = p.ProductID;
                    product.CategoryID = p.CategoryID;
                    product.MainImage = p.MainImage;
                    product.Name = p.Name;
                    product.Description = p.Description;
                    product.Price = p.Price;

                    list.productList.Add(product);
                }
                return list;
            }

        }

        public async Task<Product> getByID(int id)
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();
                var result = connection.Query<Product>("dbo.RetreiveProductByID @ProductID ", new { ProductID = id });

                Product product = new Product();
                foreach (var p in result)
                {
                    product.ProductID = p.ProductID;
                    product.CategoryID = p.CategoryID;
                    product.MainImage = p.MainImage;
                    product.ProductImages = await retrieveImages(id);
                    product.Name = p.Name;
                    product.Description = p.Description;
                    product.Price = p.Price;
                }
                return product;
            }
        }

        public async Task<ProductList> getProductByCategory(int categoryID)
        {

            string connectionstring = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionstring))
            {
                connection.Open();
                var result = await connection.QueryAsync<Product>("dbo.RetrieveProductsByCategory @CategoryID", new { CategoryID = categoryID });
                ProductList list = new ProductList();
                list.productList = new List<Product>();


                foreach (var item in result)
                {
                    Product product = new Product();

                    product.ProductID = item.ProductID;
                    product.CategoryID = item.CategoryID;
                    product.MainImage = item.MainImage;
                    product.ProductImages = await retrieveImages(item.ProductID);
                    product.Name = item.Name;
                    product.Description = item.Description;
                    product.Price = item.Price;

                    list.productList.Add(product);
                }
                return list;
            }
        }


        public async Task<ProductList> getProductByName(string productName)
        {
            string connectionstring = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionstring))
            {
                connection.Open();
                var result = await connection.QueryAsync<Product>("dbo.GetProductByName @ProductName", new { ProductName = productName });
                ProductList list = new ProductList();
                list.productList = new List<Product>();

                foreach (var item in result)
                {
                    Product product = new Product();

                    product.ProductID = item.ProductID;
                    product.CategoryID = item.CategoryID;
                    product.MainImage = item.MainImage;
                    product.ProductImages = await retrieveImages(item.ProductID);
                    product.Name = item.Name;
                    product.Description = item.Description;
                    product.Price = item.Price;

                    list.productList.Add(product);
                }
              
                return list;
            }
        }

        public async Task<ProductList> getProducts()
        {
            string connectionstring = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionstring))
            {
                connection.Open();
                var result = await connection.QueryAsync<Product>("dbo.RetrieveTopPick");
                ProductList list  = new ProductList();
                list.productList = new List<Product>();

                List<string> images = new List<string>();
           
                foreach (var item in result)
                {
                    Product product = new Product();
                    product.ProductID = item.ProductID;
                    product.CategoryID = item.CategoryID;
                    product.MainImage = item.MainImage;
                    product.Name = item.Name;
                    product.Description = item.Description;
                    product.Price = item.Price;
                   product.ProductImages = await retrieveImages(item.ProductID);
                    list.productList.Add(product);
                    
                }


                return list;
            }
        }

        private async Task<List<Image>> retrieveImages(int productID)
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionString))
            {

                connection.Open();
                var result = await connection.QueryAsync<Image>("dbo.RetrieveProductImages @ProductID", new { ProductID = productID });

                List<Image> urls = new List<Image>();

               
                foreach (var item in result)
                {
                    Image im = new Image();
                    im.url = item.url.Trim();

                    urls.Add(im);
                }
   

                return urls;
            }
        }
    }
}
