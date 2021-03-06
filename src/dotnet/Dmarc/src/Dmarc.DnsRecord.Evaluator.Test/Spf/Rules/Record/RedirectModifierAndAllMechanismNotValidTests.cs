using System.Collections.Generic;
using Dmarc.DnsRecord.Evaluator.Spf.Domain;
using Dmarc.DnsRecord.Evaluator.Spf.Explainers;
using Dmarc.DnsRecord.Evaluator.Spf.Rules.Record;
using NUnit.Framework;

namespace Dmarc.DnsRecord.Evaluator.Test.Spf.Rules.Record
{
    [TestFixture]
    public class RedirectModifierAndAllMechanismNotValidTests
    {
        private RedirectModifierAndAllMechanismNotValid _rule;

        [SetUp]
        public void SetUp()
        {
            _rule = new RedirectModifierAndAllMechanismNotValid();
        }

        [TestCase(false, false, false, TestName = "No redirect term no error.")]
        [TestCase(false, true, false, TestName = "No redirect term no error.")]
        [TestCase(true, false, false, TestName = "No redirect term no error.")]
        [TestCase(true, true, true, TestName = "No redirect term no error.")]
        public void Test(bool isAllTerm, bool isRedirectTerm, bool isErrorExpected)
        {
            List<Term> terms = new List<Term>
            {
                isAllTerm ? new All(string.Empty, Qualifier.Fail) : null,
                isRedirectTerm ? new Redirect(string.Empty, new DomainSpec(string.Empty)) : null
            };

            SpfRecord spfRecord = new SpfRecord(string.Empty, new Version(string.Empty), terms, string.Empty);

            Evaluator.Rules.Error error;
            bool isErrored = _rule.IsErrored(spfRecord, out error);

            Assert.That(isErrored, Is.EqualTo(isErrorExpected));
            Assert.That(error, isErrorExpected ? Is.Not.Null : Is.Null);
        }
    }

    [TestFixture]
    public class ShouldHaveHardFailEnabledTests
    {
        private ShouldHaveHardFailAllEnabled _rule;

        [SetUp]
        public void SetUp()
        {
            _rule = new ShouldHaveHardFailAllEnabled(FakeItEasy.A.Fake<IQualifierExplainer>());
        }

        [TestCase(false, Qualifier.Neutral, false, TestName = "No all term no error.")]
        [TestCase(true, Qualifier.Neutral, true, TestName = "Neutral qualifier error.")]
        [TestCase(true, Qualifier.SoftFail, false, TestName = "SoftFail qualifier error.")]
        [TestCase(true, Qualifier.Pass, true, TestName = "Pass qualifier error.")]
        [TestCase(true, Qualifier.Fail, false, TestName = "Fail term no error.")]
        public void Test(bool isAllTerm, Qualifier qualifier, bool isErrorExpected)
        {
            List<Term> terms = new List<Term>
            {
                isAllTerm ? new All(string.Empty, qualifier) : null
            };

            SpfRecord spfRecord = new SpfRecord(string.Empty, new Version(string.Empty), terms, string.Empty);

            Evaluator.Rules.Error error;
            bool isErrored = _rule.IsErrored(spfRecord, out error);

            Assert.That(isErrored, Is.EqualTo(isErrorExpected));
            Assert.That(error, isErrorExpected ? Is.Not.Null : Is.Null);
        }
    }
}
