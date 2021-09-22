using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ShopService.DataAccess.Models;
using ShopService.DataAccess.Repository;


namespace ShopService.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class OrdersController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public OrdersController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpPut]
        public OrderNumber Put([FromBody] Order order)
        {
            OrdersRepository repo = new OrdersRepository(_configuration);
            string message = repo.postOrder(order);
            OrderNumber orderNum = new OrderNumber();
            orderNum.orderNumber = message;

            return orderNum;
        }

        [HttpGet("{userName}")]
        public async Task<OrderList> Get(string userName)
        {
            OrdersRepository repository = new OrdersRepository(_configuration);
            var result = await repository.getOrders(userName);
            return result;
        }

        [HttpGet("details/{orderNumber}")]
        public async Task<ProductList> GetDetails(string orderNumber) {

            OrdersRepository repository = new OrdersRepository(_configuration);
            var result = await repository.getOrderDetails(orderNumber);
            return result;
        
        }
    }
}
