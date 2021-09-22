using ShopService.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace ShopService.DataAccess.Models
{
   public class ProductList
    {
        public List<Product> productList { get; set; }
        public string TotalSum { get; set; }
    }
}
