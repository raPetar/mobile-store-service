using ShopService.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace ShopService.DataAccess.Models
{
    public class Order
    {
        public string UserName { get; set; }
        public Guid OrderNumber { get; set; }
        public string DateOfPurchase { get; set; }
        public List<OrderProduct> productList { get; set; }
    }
}
