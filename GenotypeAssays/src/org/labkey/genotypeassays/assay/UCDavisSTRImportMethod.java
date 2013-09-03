package org.labkey.genotypeassays.assay;

import au.com.bytecode.opencsv.CSVParser;
import org.apache.commons.lang3.StringUtils;
import org.labkey.api.data.Container;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.assay.AssayParser;
import org.labkey.api.laboratory.assay.DefaultAssayParser;
import org.labkey.api.laboratory.assay.ImportContext;
import org.labkey.api.laboratory.assay.ParserErrors;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.view.ViewContext;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 3/7/13
 * Time: 7:08 PM
 */
public class UCDavisSTRImportMethod extends DefaultGenotypeAssaysImportMethod
{
    @Override
    public String getName()
    {
        return "UCDavisSTR";
    }

    @Override
    public String getLabel()
    {
        return "UC Davis STR";
    }

    @Override
    public String getTooltip()
    {
        return "Choose this option to upload data directly using a CSV file in the format sent from UC Davis.  See the link below to download an example.";
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
        return AppProps.getInstance().getContextPath() + "/genotypeassays/data/UCDavis.txt";
    }

    private class Parser extends DefaultGenotypeAssayParser
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
            BufferedReader reader = null;

            try
            {
                reader = new BufferedReader(new FileReader(context.getFile()));
                StringBuilder sb = new StringBuilder();

                String line;
                int idx = 0;
                String delim = "\t";
                List<Integer> header = new ArrayList<Integer>();

                sb.append("Subject Id").append(delim);
                sb.append("Marker").append(delim);
                sb.append("Result").append(delim);
                sb.append("Comment").append(System.getProperty("line.separator"));

                CSVParser parser = new CSVParser();
                while (null != (line = reader.readLine()))
                {
                    idx++;

                    if (line == null || StringUtils.trimToNull(line.replaceAll(",", "")) == null)
                        continue;

                    String[] cells = parser.parseLine(line);

                    if (cells.length == 0)
                        continue;

                    if (idx == 1)
                    {
                        int j = 0;
                        for (String name : cells)
                        {
                            if (name != null && name.startsWith("Type"))
                            {
                                header.add(j);
                            }
                            j++;
                        }
                    }
                    else
                    {
                        String subjectId = cells[0];
                        if (StringUtils.isEmpty(subjectId))
                        {
                            errors.addError("Line " + idx + ": Missing subject Id");
                            continue;
                        }

                        String comment = cells[5];
                        if (StringUtils.isEmpty(comment))
                        {
                            comment = null;
                        }

                        for (Integer resultCol : header)
                        {
                            String value = cells[resultCol];
                            if (StringUtils.isEmpty(value))
                                continue;

                            if (!value.contains(":"))
                            {
                                errors.addError("Line " + idx + ": Improper result: " + value);
                                continue;
                            }

                            String[] tokens = value.split(":");
                            if (tokens.length > 1)
                            {
                                String marker = tokens[0];
                                String[] values = tokens[1].split("/");
                                List<Integer> integers = new ArrayList<Integer>();
                                boolean hasNonNull = false;
                                for (String v : values)
                                {
                                    try
                                    {
                                        if (StringUtils.isEmpty(v))
                                        {
                                            integers.add(0);
                                        }
                                        else
                                        {
                                            Integer i = Integer.parseInt(v);
                                            if (i > 0)
                                                hasNonNull = true;

                                            integers.add(i);
                                        }
                                    }
                                    catch (NumberFormatException e)
                                    {
                                        errors.addError("Line " + idx + ": Non-numeric allele: " + v);
                                        continue;
                                    }
                                }

                                //NOTE: if the incoming data has at least one non-zero allele, remove all 0's
                                //if the data only contains NULLs, convert to a single 0
                                if (hasNonNull)
                                {
                                    while (integers.remove(Integer.valueOf(0))){}

                                    //if there is a single non-null value, always import as though it is homozygous
                                    if (integers.size() == 1)
                                    {
                                        integers.add(integers.get(0));
                                    }
                                }
                                else
                                {
                                    integers.clear();
                                    //if we have only a single NULL call, import with a blank result.
                                    //downstream code will parse this and set a statusflag of 'No Data'
                                    integers.add(null);
                                }

                                for (Integer i : integers)
                                {
                                    sb.append(subjectId).append(delim);
                                    sb.append(marker).append(delim);
                                    sb.append(i);
                                    if (comment != null)
                                        sb.append(delim).append(comment);

                                    sb.append(System.getProperty("line.separator"));
                                }
                            }
                        }
                    }
                }

                errors.confirmNoErrors();

                return sb.toString();
            }
            catch (IOException e)
            {
                errors.addError(e.getMessage());
                throw errors.getErrors();
            }
            finally
            {
                try { if (reader != null) reader.close(); } catch (IOException e) {}
            }
        }
    }
}
