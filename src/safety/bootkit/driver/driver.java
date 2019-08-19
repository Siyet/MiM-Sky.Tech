import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.c4isr.delta.model.ModelFactory;
import org.c4isr.delta.model.binding.json.ObjectMapperFactory;
import org.c4isr.delta.model.mip4.base.IdentifierType;
import org.c4isr.delta.model.mip4.base.IsDependentIndicatorType;
import org.c4isr.delta.model.mip4.base.SourceType;
import org.c4isr.delta.model.mip4.base.UriType;
import org.c4isr.delta.model.mip4.core.IsInstanceIndicatorType;
import org.c4isr.delta.model.mip4.core.NameType;
import org.c4isr.delta.model.mip4.core.NameWrapperType;
import org.c4isr.delta.model.mip4.metadata.MetadataType;
import org.c4isr.delta.model.mip4.metadata.ReportingDataWrapperType;
import org.c4isr.delta.model.mip4.persons.PersonMilitaryStatusCodeSimpleType;
import org.c4isr.delta.model.mip4.persons.PersonMilitaryStatusCodeType;
import org.c4isr.delta.model.mip4.persons.PersonMilitaryStatusCodeWrapperType;
import org.c4isr.delta.model.mip4.persons.PersonType;

import javax.xml.datatype.DatatypeConfigurationException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Scanner;
import java.util.UUID;

public class Main {
    public static Scanner scanner = new Scanner(System.in);
    public static SendLoginGET sendLoginGET = new SendLoginGET();
    public static WorkWithItems workWithItems = new WorkWithItems();
    public static String xAuthId;

    private static final String OBJECT_UUID = "4f615bec-82b7-41a6-81e4-13fe8eb3c399";
    private static final String SOURCE_UUID = "5b781bec-82b7-41a6-81e4-13fe8eb3c399";
    private static final Date DATE = new Date();
    private static final String SOURCE = "999b657c-82b7-41a6-81e4-13fe8eb3c399";


    public static void main(String[] args) {

     ObjectMapper objectMapper = getObjectMapper(ModelFactory.getInstance());

     PersonType person = new PersonType();

     IdentifierType identifier = new IdentifierType();
     UriType uri = new UriType();
     uri.setValue(UUID.randomUUID().toString());

     SourceType source = new SourceType();
     source.setValue(authorize().toString());
     IsDependentIndicatorType dependentIndicator = new IsDependentIndicatorType();
     dependentIndicator.setValue(false);

     identifier.setUri(uri);
     identifier.setSource(source);
     identifier.setIsDependentIndicator(dependentIndicator);
     person.setIdentifier(identifier);
     ReportingDataWrapperType reportingDataWrapper = new ReportingDataWrapperType();
     MetadataType metadata = new MetadataType();
     metadata.setReportingDataWrapper(reportingDataWrapper);

     person.setBaseMetadata(metadata);
     IsInstanceIndicatorType instanceIndicator = new IsInstanceIndicatorType();
          instanceIndicator.setValue(true);

       person.setIsInstanceIndicator(instanceIndicator);
        NameType name = new NameType();
        name.setValue("Human");

        NameWrapperType nameWrapper = new NameWrapperType();
        nameWrapper.setName(name);
        PersonMilitaryStatusCodeSimpleType militaryStatusCodeSimple = PersonMilitaryStatusCodeSimpleType.MILITARY;
        PersonMilitaryStatusCodeType militaryStatusCode = new PersonMilitaryStatusCodeType();
        militaryStatusCode.setValue(militaryStatusCodeSimple);

        PersonMilitaryStatusCodeWrapperType militaryStatusCodeWrapper = new PersonMilitaryStatusCodeWrapperType();
          militaryStatusCodeWrapper.setPersonMilitaryStatusCode(militaryStatusCode);

        person.setMilitaryStatusCodeWrapper(militaryStatusCodeWrapper);


        ArrayList<PersonType> list = new ArrayList<>();
        list.add(person);

        String jsonResult = "/0x8000";
        try {
            jsonResult =  objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(list);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
        System.out.println(jsonResult);
    }

    public static String authorize(){
        try {
            xAuthId = sendLoginGET.sendLoginGet();
            return xAuthId;
        } catch (IOException e) {
            System.out.println("IO Error");
            e.printStackTrace();
        }
        return "No Id";
    }

    public static String getItems(){
        String params;
        System.out.println("Enter params of objects to search");
        params = scanner.nextLine();
        try {
            return workWithItems.getItems(params);
        } catch (IOException e) {
            System.out.println("IO Error");
            e.printStackTrace();
        }
        return "No Items";
    }

    public static String addItems(){
        String params;
        System.out.println("Enter params of objects to add");
        params = scanner.nextLine();
        try {
            return workWithItems.addOrUpdateObjects();
        } catch (IOException e) {
            System.out.println("IO Error");
        }
        return "No Items added";
    }

    public static ObjectMapper getObjectMapper(ModelFactory modelFactory){
        ObjectMapperFactory objectMapperFactory = new ObjectMapperFactory();
        return objectMapperFactory.createObjectMapper(modelFactory);
    }
}
