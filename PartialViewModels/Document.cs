namespace MixERP.Finance.PartialViewModels
{
    public sealed class Document
    {
        public string Id { get; set; }
        public string Documents { get; set; }
        public bool DisableDelete { get; set; }
        public bool DisableUpload { get; set; }
        public string UploadHandler { get; set; }
    }
}