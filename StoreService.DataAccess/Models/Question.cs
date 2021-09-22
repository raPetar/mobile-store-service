using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ShopService.Models
{
    public class Question
    {
        public int QuestionID { get; set; }
        public int MainThread { get; set; }
        public string UserName { get; set; }
        public string Text { get; set; }
    }
}
