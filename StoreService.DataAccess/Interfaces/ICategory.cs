using ShopService.DataAccess.Models;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace ShopService.DataAccess.Interfaces
{
    public interface ICategory
    {
        Task<CategoryList> RetrieveCategories();
    }
}
