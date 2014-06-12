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
public class QuantStudioImportMethod extends DefaultSnpAssayImportMethod
{
    @Override
    public String getName()
    {
        return "QuantStudio";
    }

    @Override
    public String getLabel()
    {
        return "Quant Studio";
    }

    @Override
    public String getTooltip()
    {
        return "Choose this option to upload data directly using the output from Quant Studio.  See the link below to download an example.";
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
        return AppProps.getInstance().getContextPath() + "/genotypeassays/data/QuantStudioExample.txt";
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

                List<String> toAdd = new ArrayList<>();
                toAdd.add("Subject Id");
                toAdd.add("Marker");
                toAdd.add("NT");
                toAdd.add("Status Flag");
                out.writeNext(toAdd.toArray(new String[toAdd.size()]));

                for (List<String> cells : getFileLines(context.getFile()))
                {
                    idx++;
                    String line = StringUtils.trimToNull(StringUtils.join(cells, "\n"));
                    if (StringUtils.isEmpty(line))
                        continue;

                    if (cells.size() == 0)
                        continue;

                    if (line.startsWith("#"))
                    {
                        if (line.startsWith("# Instrument Type :"))
                        {
                            String[] tokens = line.split(" : ");
                            context.getRunProperties().put("instrument", tokens[1]);
                        }
                        else if (line.startsWith("# Experiment Type :"))
                        {
                            String[] tokens = line.split(" : ");
                            context.getRunProperties().put("assayType", tokens[1]);
                        }
                        else if (line.startsWith("# Study Name :"))
                        {
                            String[] tokens = line.split(" : ");
                            context.getRunProperties().put("Name", tokens[1]);
                        }

                        continue;
                    }
                    else if ("Assay ID".equals(cells.get(0)))
                    {
                        //this indicates we reached the end of the true results and hit the summary, which we ignore
                        break;
                    }
                    else if ("Sample ID".equals(cells.get(0)))
                    {
                        //this is the header line
                        continue;
                    }
                    else
                    {
                        if (cells.size() < 4)
                        {
                            errors.addError("Too few elements in line " + idx + ".  Expected 4, was: " + cells.size());
                            continue;
                        }

                        String subjectId = cells.get(0);
                        if (StringUtils.isEmpty(subjectId))
                        {
                            errors.addError("Line " + idx + ": Missing subject Id");
                            continue;
                        }

                        //no template controls
                        if ("NTC1".equals(subjectId) || "NTC2".equals(subjectId))
                        {
                            continue;
                        }

                        String snpName = cells.get(1);
                        if (StringUtils.isEmpty(snpName))
                        {
                            errors.addError("Line " + idx + ": Missing SNP Name");
                            continue;
                        }

                        String allele = cells.get(2);
                        if (StringUtils.isEmpty(allele))
                        {
                            errors.addError("Line " + idx + ": Missing SNP Call");
                            continue;
                        }

                        String status_flag = null;
                        if ("NOAMP".equalsIgnoreCase(allele) || "UND".equalsIgnoreCase(allele) || "INV".equalsIgnoreCase(allele))
                        {
                            status_flag = "No Data";
                        }

                        toAdd = new ArrayList<>();
                        toAdd.add(subjectId);
                        toAdd.add(snpName);
                        toAdd.add(allele);
                        toAdd.add(status_flag);
                        out.writeNext(toAdd.toArray(new String[toAdd.size()]));
                    }
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
