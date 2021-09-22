using ShopService.DataAccess.Models;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace ShopService.DataAccess.Interfaces
{
    interface IOrders
    {
        string postOrder(Order order);

       Task<OrderList> getOrders(string userName);

        Task<ProductList> getOrderDetails(string orderNumber);
    }
}
