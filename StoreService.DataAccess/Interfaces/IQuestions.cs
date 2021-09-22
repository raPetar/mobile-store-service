using ShopService.DataAccess.Models;
using ShopService.Models;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace ShopService.DataAccess.Interfaces
{
  public  interface IQuestions
    {
        QuestionList GetQuestions(int productID);
    }
}
