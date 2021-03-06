using System.Collections.Generic;
using Dmarc.DnsRecord.Evaluator.Dmarc.Domain;
using Dmarc.DnsRecord.Evaluator.Rules;

namespace Dmarc.DnsRecord.Evaluator.Dmarc.Parsers
{
    public interface IDmarcConfigParser
    {
        DmarcConfig Parse(Contract.Domain.DmarcConfig dmarcDomainConfig);
    }

    public class DmarcConfigParser : IDmarcConfigParser
    {
        private readonly IDmarcRecordParser _recordParser;
        private readonly IRuleEvaluator<DmarcConfig> _configRuleEvaluator;

        public DmarcConfigParser(IDmarcRecordParser recordParser,
            IRuleEvaluator<DmarcConfig> configRuleEvaluator)
        {
            _recordParser = recordParser;
            _configRuleEvaluator = configRuleEvaluator;
        }

        public DmarcConfig Parse(Contract.Domain.DmarcConfig dmarcDomainConfig)
        {
            List<DmarcRecord> records = new List<DmarcRecord>();

            foreach (string dmarcRecord in dmarcDomainConfig.Records)
            {
                DmarcRecord record;
                if (_recordParser.TryParse(dmarcRecord, dmarcDomainConfig.Domain.Name, out record))
                {
                    records.Add(record);
                }
            }

            DmarcConfig dmarcConfig = new DmarcConfig(records, dmarcDomainConfig.Domain.Name, dmarcDomainConfig.LastChecked);

            dmarcConfig.AddErrors(_configRuleEvaluator.Evaluate(dmarcConfig));

            return dmarcConfig;
        }
    }
}
