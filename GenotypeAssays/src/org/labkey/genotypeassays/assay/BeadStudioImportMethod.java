package org.labkey.genotypeassays.assay;

import au.com.bytecode.opencsv.CSVWriter;
import org.apache.commons.lang3.StringUtils;
import org.labkey.api.data.Container;
import org.labkey.api.data.ConvertHelper;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.assay.AssayParser;
import org.labkey.api.laboratory.assay.DefaultAssayParser;
import org.labkey.api.laboratory.assay.ImportContext;
import org.labkey.api.laboratory.assay.ParserErrors;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.view.ViewContext;

import java.io.IOException;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 3/7/13
 * Time: 7:08 PM
 */
public class BeadStudioImportMethod extends DefaultSnpAssayImportMethod
{
    @Override
    public String getName()
    {
        return "IlluminaBeadStudio";
    }

    @Override
    public String getLabel()
    {
        return "Illumina Bead Studio";
    }

    @Override
    public String getTooltip()
    {
        return "Choose this option to upload data directly using the output from Illumina BeadStudio.  See the link below to download an example.";
    }

    @Override
    public boolean hideTemplateDownload()
    {
        return true;
    }

    @Override
    public AssayParser getFileParser(Container c, User u, int assayId)
    {
        return new Parser(this, c, u, assayId);
    }

    @Override
    public String getExampleDataUrl(ViewContext ctx)
    {
        return AppProps.getInstance().getContextPath() + "/genotypeassays/data/BeadStudioExample.xlsx";
    }

    private class Parser extends DefaultAssayParser
    {
        public Parser(AssayImportMethod method, Container c, User u, int assayId)
        {
            super(method, c, u, assayId);
        }

        /**
         * We read the entire raw file, transforming into 1 row per sample/test combination
         * We return a TSV string, which is later fed into a TabLoader.  This is done so we let that code handle type conversion
         */
        @Override
        protected String readRawFile(ImportContext context) throws BatchValidationException
        {
            ParserErrors errors = context.getErrors();
            try (StringWriter sw = new StringWriter(); CSVWriter out = new CSVWriter(sw, '\t'))
            {
                int idx = 0;
                boolean inData = false;

                List<String> toAdd = new ArrayList<>();
                toAdd.add("Subject Id");
                toAdd.add("Marker");
                toAdd.add("Ref_NT_Name");
                toAdd.add("Strand");
                toAdd.add("Position");
                toAdd.add("NT");
                toAdd.add("Confidence");
                out.writeNext(toAdd.toArray(new String[toAdd.size()]));

                for (List<String> cells : getFileLines(context.getFile()))
                {
                    idx++;
                    String line = StringUtils.trimToNull(StringUtils.join(cells, "\n"));
                    if (StringUtils.isEmpty(line))
                        continue;

                    if (cells.size() == 0)
                        continue;

                    if ("Processing Date".equals(cells.get(0)))
                    {
                        context.getRunProperties().put("runDate", ConvertHelper.convert(cells.get(1), Date.class));
                        continue;
                    }
                    else if ("BSGT Version".equals(cells.get(0)))
                    {
                        context.getRunProperties().put("method", "BSGT Version: " + cells.get(1));
                        continue;
                    }
                    else if ("SNP Name".equals(cells.get(0)))
                    {
                        inData = true;
                        continue;
                    }

                    if (!inData)
                    {
                        continue;
                    }

                    if (cells.size() < 20)
                    {
                        errors.addError("Too few elements in line " + idx + ".  Expected 20, was: " + cells.size());
                        continue;
                    }

                    String snpName = cells.get(0);
                    if (StringUtils.isEmpty(snpName))
                    {
                        errors.addError("Line " + idx + ": Missing SNP Name");
                        continue;
                    }

                    String subjectId = cells.get(1);
                    if (StringUtils.isEmpty(subjectId))
                    {
                        errors.addError("Line " + idx + ": Missing subject Id");
                        continue;
                    }

                    if ("empty".equalsIgnoreCase(cells.get(1)))
                    {
                        continue;
                    }

                    String strand = cells.get(7);
                    if (StringUtils.isEmpty(strand))
                    {
                        errors.addError("Line " + idx + ": Missing strand");
                        continue;
                    }
                    else if ("TOP".equals(strand))
                    {
                        strand = "+";
                    }
                    else if ("BOT".equals(strand))
                    {
                        strand = "-";
                    }
                    else
                    {
                        errors.addError("Line " + idx + ": Unknown value for strand.  Expected either TOP or BOT, was: " + strand);
                        continue;
                    }

                    String chrStr = cells.get(14);
                    if (StringUtils.isEmpty(chrStr))
                    {
                        errors.addError("Line " + idx + ": Missing chromosome");
                        continue;
                    }
                    Integer chr = ConvertHelper.convert(chrStr, Integer.class);

                    String positionStr = cells.get(15);
                    if (StringUtils.isEmpty(positionStr))
                    {
                        errors.addError("Line " + idx + ": Missing position");
                        continue;
                    }

                    Long position = ((Double)Double.parseDouble(positionStr)).longValue();

                    String alleleA = cells.get(3);
                    String alleleB = cells.get(4);
                    if (StringUtils.isEmpty(alleleA) && StringUtils.isEmpty(alleleB))
                    {
                        errors.addError("Line " + idx + ": Missing SNPs");
                        continue;
                    }

                    String snp = "";
                    if (!StringUtils.isEmpty(alleleA))
                        snp += alleleA;

                    if (!StringUtils.isEmpty(alleleB))
                    {
                        if (!StringUtils.isEmpty(snp))
                            snp += "/";

                        snp += alleleB;
                    }

                    String confidence = cells.get(5);
                    if ("NaN".equals(confidence))
                    {
                        confidence = "";
                    }

                    toAdd = new ArrayList<>();
                    toAdd.add(subjectId);
                    toAdd.add(snpName);
                    toAdd.add("chr " + chr.toString());
                    toAdd.add(strand);
                    toAdd.add(position.toString());
                    toAdd.add(snp);
                    toAdd.add(confidence);
                    out.writeNext(toAdd.toArray(new String[toAdd.size()]));
                }

                errors.confirmNoErrors();

                return sw.toString();
            }
            catch (IOException e)
            {
                errors.addError(e.getMessage());
                throw errors.getErrors();
            }
        }
    }
}
