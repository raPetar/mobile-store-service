using ShopService.DataAccess.Models;
using ShopService.Models;
using System.Threading.Tasks;

namespace ShopService.DataAccess.Interfaces
{
    public interface IProducts
    {
        Task<Product> getByID(int id);
        Task<ProductList> getProducts();
        Task<ProductList> getProductByName(string productName);
        Task<ProductList> getProductByCategory(int categoryID);
        Task<ProductList> getBrowseProducts(int getNextProducts);
    }
}
