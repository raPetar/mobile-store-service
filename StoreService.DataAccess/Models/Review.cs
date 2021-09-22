using System;
using System.Collections.Generic;
using System.Text;

namespace ShopService.DataAccess.Models
{
   public class Review
    {

        public int ReviewID { get; set; }
        public int MainThread { get; set; }
        public string UserName { get; set; }
        public string Text { get; set; }
    }
}
