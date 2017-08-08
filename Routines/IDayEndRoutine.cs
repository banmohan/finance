using System.Threading.Tasks;

namespace MixERP.Finance.Routines
{
    public interface IDayEndRoutine
    {
        string Name { get; }
        int SequenceId { get; }
        Task<bool> PerformAsync(string tenant, int officeId);
    }
}