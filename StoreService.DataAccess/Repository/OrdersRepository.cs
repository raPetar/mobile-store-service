using Dapper;
using Microsoft.Extensions.Configuration;
using ShopService.DataAccess.Interfaces;
using ShopService.DataAccess.Models;
using ShopService.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ShopService.DataAccess.Repository
{
    public class OrdersRepository : IOrders
    {
        private readonly IConfiguration _configuration;
        public OrdersRepository(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task<ProductList> getOrderDetails(string orderNumber)
        {

            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionString))
            {
               
                List<Product> products = new List<Product>();
                var result = await connection.QueryAsync<Product>("dbo.RetrieveOrderDetails @OrderNumber", new { orderNumber });

                ProductList productList = new ProductList();
                productList.productList = products;
                foreach (var p in result)
                {
                    Product product = new Product();
                    product.ProductID = p.ProductID;
                    product.CategoryID = p.CategoryID;
                    product.MainImage = p.MainImage;
                    product.Name = p.Name;
                    product.Description = p.Description;
                    product.Price = p.Price;
              
                   
                    productList.TotalSum = p.TotalSum.ToString();

                    products.Add(product);
                }
                

                return productList;
                    
            }
        }

        public async Task<OrderList> getOrders(string UserName)
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionString))
            {
                var result = await connection.QueryAsync<Order>("dbo.RetrieveOrders @UserName", new { UserName });

                OrderList list = new OrderList();
                list.orderList = new List<Order>();
                foreach (var item in result)
                {
                    Order order = new Order();
                    order.OrderNumber = item.OrderNumber;
                    order.DateOfPurchase = item.DateOfPurchase;
                    list.orderList.Add(order);
                }
                return list;
            }
        }

        public string postOrder(Order order)
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionString))
            {
                DynamicParameters dynamicParameters = new DynamicParameters();

                connection.Open();
                decimal totalSum = 0;
                List<Product> productList = new List<Product>();
                List<OrderProduct> orderProductList = order.productList;
                Product product = new Product();
                foreach (var p2 in orderProductList)
                {
                    var result = connection.Query<Product>("dbo.RetreiveProductByID @ProductID", new { p2.ProductID });
                    foreach (var p in result)
                    {
                        product.ProductID = p.ProductID;
                        product.CategoryID = p.CategoryID;
                        product.MainImage = p.MainImage;
                        product.Name = p.Name;
                        product.Description = p.Description;
                        product.Price = p.Price;
                    }
                    productList.Add(product);
                }

                foreach (var p in productList)
                {
                    for (int i = 0; i < orderProductList.Count(); i++)
                    {
                        if (p.ProductID == orderProductList[i].ProductID)
                        {
                            totalSum += p.Price * orderProductList[i].Quantity;
                        }
                    }
                }

                dynamicParameters.Add("UserName", order.UserName);
                dynamicParameters.Add("TotalSum", totalSum);
                dynamicParameters.Add("OrderID", dbType: DbType.Int32, direction: ParameterDirection.Output);
                dynamicParameters.Add("OrderNumber", dbType: DbType.Guid, direction: ParameterDirection.Output);
                connection.Query<Order>("dbo.PostOrder", dynamicParameters, commandType: CommandType.StoredProcedure);

                int orderID = dynamicParameters.Get<int>("OrderID");
                string orderNumber = dynamicParameters.Get<Guid>("OrderNumber").ToString();

                foreach (var item in orderProductList)
                {
                    connection.Query<Order>("dbo.PostOrderProducts @OrderID, @ProductID, @Quantity", new { orderID, item.ProductID, item.Quantity });
                }


                if (orderNumber != null)
                {
                    return orderNumber;
                }
                else
                {
                    return new string("An error occured, please try again");
                }
            }
        }
    }
}
