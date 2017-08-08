using System.Threading.Tasks;

namespace MixERP.Finance.Routines
{
    public class DayEndRoutine : IDayEndRoutine
    {
        public string Name { get; } = "Day End Routine";
        public int SequenceId { get; } = 1000;

        public async Task<bool> PerformAsync(string tenant, int officeId)
        {
            await Task.Delay(0).ConfigureAwait(false);
            return true;
        }
    }
}