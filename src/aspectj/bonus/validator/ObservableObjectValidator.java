package aspectj.bonus.validator;

import aspectj.validator.Validator;

public interface ObservableObjectValidator extends ObservableObject {

	public void initialize();
	
	public void fieldChanged(String fieldName, Object oldValue, Object newValue);
	
	public void addValidator(String propertyName, Validator<String> aValidate);
}
